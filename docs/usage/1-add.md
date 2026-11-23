# 1. Add the backend module

## 1.1. Create the module directory

Create a new "state-backend" module directory, alongside your own infrastructure.

For example, if you describe your project's infrastructure within an "infra" directory, then create the new "state-backend" directory in there.

```text
your-repository/
└─ infra/
    ├─ state-backend/ *
    └─ website/
```

!!! info "You don't have to call it "state-backend""

    This guide will refer to the new module as "state-backend", but you can name it anything you like.

## 1.2. Create `main.tf`

Create `main.tf` inside the new module directory.

```text
your-repository/
└─ infra/
    └─ state-backend/
       └─ main.tf *
```

Copy and paste this definition into the file:

```hcl
module "state" {
  source   = "git::https://github.com/cariad/terraform-scaleway-tofu-state.git?ref=v0.1.0"
  bucket   = "..."
  workload = "..."
}
```

Set the following values:

- **`source` — URL of `cariad/terraform-scaleway-tofu-state`**

    Ensure `ref` is the release that you want to use. Check [Releases](https://github.com/cariad/terraform-scaleway-tofu-state/releases) for the latest.

- **`bucket` — name of the bucket to create**

    The name must be globally unique amongst all Scaleway customers, so consider adding a timestamp or random characters to reduce the chance of a collision.

    For example, use something like `"example-state-20261015"` rather than just `"state"`.

- **`workload` — a name for your project**

    This name is used for the Scaleway project and reader/writer applications.

    If your project is a website, for example, then `workload` can be its domain name — like `"example.com"`.

- **`region` — *optional* geographic region to store your state in**

    The bucket will be created in Paris, France, by default. To override this, set `region` to the code of the [Scaleway region](https://www.scaleway.com/en/product-availability-by-region/?categories=storage) you prefer, such as `nl-ams`.

!!! danger "Choose the bucket name and region carefully"

    Neither the bucket name nor region can be changed after their initial deployment. Changing either of these will cause Scaleway to try to destroy and recreate the bucket, which will fail because this module applies deletion protection.

## 1.3. Create `versions.tofu`

Create `versions.tofu` inside the new module directory.

```text
your-repository/
└─ infra/
    └─ state-backend/
       ├─ main.tf
       └─ versions.tofu *
```

Copy and paste this configuration into the file:

```hcl
language {
  compatible_with {
    opentofu = "~> 1.13.0"
  }
}

terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.91.0"
    }
  }
}
```

## 1.4. Ignore the module's state and working files

Add these entries to your `.gitignore`:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
```

!!! warning "The state-backend's own `*.tfstate`"

    The state-backend's own `*.tfstate` must not be committed.

    You are responsible for backing it up. Keep it secret, keep it safe.

The code for the state-backend module is done! Now [deploy](2-deploy.md) it.
