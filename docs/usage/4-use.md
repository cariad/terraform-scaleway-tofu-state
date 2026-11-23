# 4. Point your infrastructure at the backend

!!! warning "New projects"

    If your project doesn't have any infrastructure yet — i.e. you're setting up a new project, and adding the state-backend was the first task — then hold here and add the rest of your infrastructure before continuing. This steps needs to add configuration to that infrastructure.

## 4.1 Create `backend.tf`

Create `backend.tf` inside the module that you want to configure to use the state backend.

For example, if you have a "website" module that deploys website infrastructure, then create `backend.tf` in there.

```text
your-repository/
└─ infra/
    ├─ state-backend/
    └─ website/
       └─ backend.tf *
```

Copy and paste this definition into the file:

```hcl
terraform {
  backend "s3" {
    bucket                      = "..."
    key                         = "state/terraform.tfstate"
    region                      = "fr-par"
    skip_credentials_validation = true # Scaleway has no AWS STS
    skip_metadata_api_check     = true # Scaleway has no AWS EC2 metadata service
    skip_region_validation      = true # Scaleway uses different region codes
    skip_requesting_account_id  = true # Scaleway has no AWS account ID
    use_lockfile                = true

    endpoints = {
      s3 = "https://s3.fr-par.scw.cloud"
    }
  }
}
```

Set the following values:

- **`bucket` — the name of the state bucket**

    Copy the `bucket` name you set in [`main.tf`](1-add.md#12-create-maintf).

- **`key` — where to save the state in the bucket**

    You only need to change this from `"state/terraform.tfstate"` if you add this backend to multiple modules.

    !!! danger "Give every module a unique key"

        If you add this backend to more than one module in your project, then make sure they each have a unique key, otherwise they'll overwrite each other.

        So, for example, if you have a database and a website, then set their keys to something like `"database/terraform.tfstate"` and `"website/terraform.tfstate"`.

- **`region` — the Scaleway region where the bucket resides**

    Change this only if you override the default region in [`main.tf`](1-add.md#12-create-maintf).

    If you didn't set a region in `main.tf` then leave this as `fr-par`, otherwise copy the region here.

- **`endpoints.s3` — the S3 API endpoint where the bucket resides**

    Change this only if you override the default region in [`main.tf`](1-add.md#12-create-maintf).

    If you didn't set a region in `main.tf` then leave this as `https://s3.fr-par.scw.cloud`, otherwise replace `fr-par` with the region you chose.

## 4.2. Set temporary environment variables

Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables to the *writer* application's API key pair.

```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
```

!!! question "Why `AWS_` for Scaleway?"

    Scaleway's Object Storage has an AWS S3-compatible API, which is also why we use an "s3" backend in [`backend.tf`](#41-create-backendtf).

    The "s3" backend reads its credentials from these `AWS_` environment variables, not the Scaleway provider's `SCW_` ones.

## 4.3. Reinitialise your infrastructure module to use the backend

Run `tofu` to initialise each of the modules that you added a `backend.tf` to.

```text
your-repository/
└─ infra/
    ├─ state-backend/
    └─ website/
       └─ backend.tf
```

For example, if you added `backend.tf` to a website module at `infra/website` then run:

```bash
tofu -chdir=infra/website init -migrate-state
```

If it succeeds, then you should see a message like:

```text
OpenTofu has been successfully initialized!
```

Now, whether you perform deployments in CI/CD or from your local machine, you need to set some [environment variables](5-variables.md).
