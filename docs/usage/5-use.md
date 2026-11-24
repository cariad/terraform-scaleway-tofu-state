# 5. Point your infrastructure at the backend

!!! warning "New projects"

    If your project doesn't have any infrastructure yet — i.e. you're setting up a new project, and adding the state-backend was the first task — then hold here and add the rest of your infrastructure before continuing. This steps needs to add configuration to that infrastructure.

## 5.1. Create `backend.tofu`

Create `backend.tofu` inside the module that you want to configure to use the state backend.

For example, if you have a "website" module that deploys website infrastructure, then create `backend.tofu` in there.

```text
your-repository/
└─ infra/
    ├─ state-backend/
    └─ website/
       └─ backend.tofu *
```

Copy and paste this template into the file, then fill in the `state_region`, `bucket`, and `key`:

```hcl
locals {
  # The region to store state in. Copy "region" from "main.tf" if you set it
  # there, otherwise leave this as "fr-par".
  state_region = "fr-par"
}

terraform {
  backend "s3" {
    # Name of the bucket to store state in. Copy "bucket" from "main.tf".
    #
    # bucket                    = "example-state-20261015"
    bucket                      = "..."

    # The path to save the state at in the bucket.
    #
    # You only need to change this from "state/terraform.tfstate" if multiple
    # modules will be writing to this same bucket.
    #
    # So, for example, if you have a database and a website, then set their
    # keys to something like "database/terraform.tfstate" and
    # "website/terraform.tfstate", otherwise each module will overwrite the
    # other's state file.
    key                         = "state/terraform.tfstate"

    region                      = local.state_region
    skip_credentials_validation = true # Scaleway has no AWS STS
    skip_metadata_api_check     = true # Scaleway has no AWS EC2 metadata service
    skip_region_validation      = true # Scaleway uses different region codes
    skip_requesting_account_id  = true # Scaleway has no AWS account ID
    use_lockfile                = true

    endpoints = {
      s3 = "https://s3.${local.state_region}.scw.cloud"
    }
  }
}
```

## 5.2. Set temporary environment variables

Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to the *writer* application's API key pair.

```shell
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

!!! question "Why `AWS_` for Scaleway?"

    Scaleway's Object Storage has an AWS S3-compatible API, which is also why we use an "s3" backend in `backend.tofu`.

    The "s3" backend reads its credentials from these `AWS_` environment variables, not the Scaleway provider's `SCW_` ones.

## 5.3. Reinitialise your infrastructure module to use the backend

Run `tofu` to initialise each of the modules that you added a `backend.tofu` to.

```text
your-repository/
└─ infra/
    ├─ state-backend/
    └─ website/
       └─ backend.tofu
```

!!! warning "Your infrastructure module path"

    If your infrastructure module isn't in `infra/website` then be sure you update the `-chdir=` path before you run the command.

For example, if you added `backend.tofu` to a website module at `infra/website` then run:

```shell
tofu -chdir=infra/website init -migrate-state
```

If it succeeds, then you should see a message like:

```text
OpenTofu has been successfully initialized!
```
