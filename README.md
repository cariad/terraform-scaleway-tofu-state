# An OpenTofu module to store OpenTofu state in Scaleway

[cariad/terraform-scaleway-tofu-state](https://github.com/cariad/terraform-scaleway-tofu-state) is an OpenTofu module that deploys infrastructure to [Scaleway](https://www.scaleway.com) to store OpenTofu state.

This is intended to be deployed as a manual bootstrap, so that the rest of your infrastructure has somewhere to keep its state.

## Prerequisites

- Your own [Scaleway](https://www.scaleway.com) account. You must provision this yourself, and you're responsible for your own charges.
- [OpenTofu](https://opentofu.org) 1.12 or later.

## Infrastructure

This module creates:

- **A Scaleway project** to hold the bucket.
- **A versioned, encrypted bucket** that holds the state and its most recent versions, in case you ever need to roll back.
- **A "reader" application and policy** for plans, which **can only read** the state and **can't lock** it.
- **A "writer" application and policy** for applies, which **can read and write** the state, and **can lock and unlock** it.

This module won't create the API keys that you'll need, because OpenTofu would store their secrets in the bootstrap's state. You are responsible for creating, storing, and rotating the API keys yourself.

## Usage

1. Create a new root module, alongside your own infrastructure, which uses `cariad/terraform-scaleway-tofu-state`.

   This guide will name the new module `bootstrap`, but you can use any name you want.

   ```text
   your-repository/
   └── infra/
       ├── bootstrap/   Uses cariad/terraform-scaleway-tofu-state - keeps its state in a local file
       └── your-infra/  Your custom infrastructure                - keeps its state in the bootstrapped bucket
   ```

1. Create `infra/bootstrap/main.tf`.

   ```hcl
   module "state" {
     source = "git::https://github.com/cariad/terraform-scaleway-tofu-state.git?ref=v1.0.0"

     bucket   = "state-bucket-name"   # The new bucket's name, e.g. "example-state-20261015"
     workload = "your-workload-name"  # Your workload's name, e.g. "example.com"
   }
   ```

   Make sure you pin the source `ref` to the specific release you want to deploy.

   The bucket name must be globally unique amongst all Scaleway customers, so consider adding a timestamp or random characters to reduce the chance of a collision. For example, use something like `"example-state-20261015"` rather than just `"state"`.

   Your workload is the infrastructure whose state the bucket will hold, such as a website. Its name, such as the website's domain, becomes the name of the Scaleway project, and of the `<workload>-reader` and `<workload>-writer` IAM applications and policies.

   By default, the bucket will be created in Paris, France. To override this, set `region` to the code of the [Scaleway region](https://www.scaleway.com/en/product-availability-by-region/?categories=storage) you prefer, such as `nl-ams`.

   **Choose the bucket name and region carefully.** You can't change either after the first apply, because that would replace the bucket, and the module prevents the bucket from being destroyed.

1. Create `infra/bootstrap/versions.tofu`:

   ```hcl
   language {
     compatible_with {
       opentofu = "~> 1.12.0"
     }
   }

   terraform {
     required_providers {
       scaleway = {
         source  = "scaleway/scaleway"
         version = "~> 2.83.1"
       }
     }
   }
   ```

   Pin the OpenTofu and provider versions you use. The module itself needs OpenTofu 1.12 or later, and `scaleway/scaleway` 2.83.1 or later.

   Name this file `.tofu` rather than `.tf`, because some tools that read `.tf` files fail on a `language` block in a `.tf` file.

   You don't need a `provider` block, because `scaleway/scaleway` reads credentials from environment variables.

1. Make sure Git ignores the bootstrap's local state and OpenTofu's working files.

   ```gitignore
   .terraform/
   *.tfstate
   *.tfstate.*
   ```

   The state file must not be committed, so you need to back it up somewhere private instead.

   Do commit `.terraform.lock.hcl`, though, because it pins the provider's exact version.

   The code for the bootstrap module is now done!

1. In the Scaleway console, generate an API key pair (an access key and a secret key) for yourself that expires in an hour.

   If Scaleway asks if the key will be used for Object Storage, say *no*. The bootstrap will *create* Object Storage, but it won't *use* it.

1. Set the key pair and your organisation's ID as environment variables in a local shell:

   ```bash
   export SCW_ACCESS_KEY="..."
   export SCW_SECRET_KEY="..."
   export SCW_DEFAULT_ORGANIZATION_ID="..."
   ```

1. Initialise the bootstrap module.

   ```bash
   tofu -chdir=infra/bootstrap init
   ```

1. Review the plan and apply it:

   ```bash
   tofu -chdir=infra/bootstrap apply
   ```

1. You don't need your one-hour API key any more, so delete it from the Scaleway console.

1. Back up `infra/bootstrap/terraform.tfstate`. The bootstrap can't keep its state in the bucket it creates, so that file is its only record.

   When that state file is stored somewhere safe, the bootstrap initialisation is done!

1. In the Scaleway console, generate an API key for each of the two new applications: `<workload>-reader` and `<workload>-writer`, where `<workload>` is the workload name you gave in `infra/bootstrap/main.tf`.

   Set each key's preferred Object Storage project to the Scaleway project that the bootstrap created — also called `<workload>` — otherwise OpenTofu won't find the bucket.

   New policies can take a few minutes to take effect in Scaleway. If any of the following steps gives an "access denied" error, wait a few minutes before trying again.

   Store both of these new API key pairs somewhere safe, then that's the manual IAM setup done!

1. In your own infrastructure directory now, create `infra/your-infra/backend.tf`.

   ```hcl
   # Keep this module's state in the bucket that `infra/bootstrap/` creates.
   #
   # Scaleway Object Storage speaks the S3 API, so we point the `s3` backend at
   # Scaleway. The Scaleway API key pair must be set as `AWS_ACCESS_KEY_ID` and
   # `AWS_SECRET_ACCESS_KEY`.
   terraform {
     backend "s3" {
       bucket = "state-bucket-name"          # Copy from `infra/bootstrap/main.tf`

       endpoints = {
         s3 = "https://s3.fr-par.scw.cloud"  # Replace "fr-par" if you overrode the region in `infra/bootstrap/main.tf`
       }

       key    = "site/terraform.tfstate"
       region = "fr-par"                     # Replace "fr-par" if you overrode the region in `infra/bootstrap/main.tf`

       # Skip the checks that only work in AWS:
       skip_credentials_validation = true    # Scaleway has no AWS STS
       skip_metadata_api_check     = true    # Scaleway has no AWS EC2 metadata service
       skip_region_validation      = true    # Scaleway uses different region codes
       skip_requesting_account_id  = true    # Scaleway has no AWS account ID

       use_lockfile = true
     }
   }
   ```

   If you overrode the default region of Paris, France (`fr-par`) in `infra/bootstrap/main.tf`, then make sure you match the S3 endpoint and region in this file too.

   If more than one root module keeps its state in the bucket, give each one its own `key`, such as `dns/terraform.tfstate`. Otherwise they'll overwrite each other's state.

   Now, finally, you're ready to deploy!

1. Wherever you perform OpenTofu plans (e.g. CI, locally, etc), set the `<workload>-reader` API key pair as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables, and plan with `-lock=false`:

   ```bash
   tofu plan -lock=false
   ```

1. Wherever you perform OpenTofu applies (e.g. CI, locally, etc), set the `<workload>-writer` API key pair as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

## Retiring the bucket

The module intentionally prevents destruction of the bucket as a precaution against accidents, so `tofu destroy` will fail.

If you're *sure* you want to delete everything:

1. Make sure nothing keeps its state in the bucket any more: destroy or migrate every root module whose `backend` block points at the bucket, such as `infra/your-infra`. The last step deletes every version of every object in the bucket, so any state still in there would be lost for good, and the infrastructure it describes would be orphaned.
1. Copy your backed-up `terraform.tfstate` into `infra/bootstrap/`.
1. Make OpenTofu forget the module's resources, without deleting them:

   ```bash
   tofu -chdir=infra/bootstrap state rm module.state
   ```

1. Delete the `module "state"` block, or the whole `infra/bootstrap` directory — otherwise, the next apply would create everything again.
1. In the Scaleway console, delete the reader and writer API keys. Then manually empty the bucket, including every old version and delete marker, and delete the bucket, applications, policies and Scaleway project.

## AI disclosure

This project is developed by me, Cariad Eccleston, with the assistance of:

- *Claude Opus 5.5* in Claude Code for research, code, tests, and reviews
- *GitHub Copilot* for reviews

I own the scope and requirements of the project, and I make the design decisions: the interfaces, the structure, and the trade-offs.

Claude writes the first drafts of code and tests, which I review for correctness and quality, then revise with Claude or by hand.

Claude writes the first draft of documentation, which I rewrite in my own voice.

When I'm satisfied, Claude reviews the workspace, and we act *only* on the feedback that I agree with, before I check my understanding and commit.

Finally, Copilot and I review every pull request, before I merge it.

I retain full responsibility for all changes that land in the `main` branch.

AI-assisted contributions are welcome — see [`CONTRIBUTING.md`](CONTRIBUTING.md).

## Licence

MIT. See [`LICENSE`](LICENSE).
