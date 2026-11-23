# How do I undeploy it?

`cariad/terraform-scaleway-tofu-state` intentionally prevents destruction of the bucket as a precaution against accidents, so `tofu destroy` will fail.

If you're *sure* you want to delete everything:

1. Migrate every module whose `backend` block points at the bucket to your new backend.

1. Restore your backed-up `terraform.tfstate` into `infra/state-backend/` (or wherever you put this backend module).

1. Make OpenTofu forget this module's resources:

    ```shell
    tofu -chdir=infra/state-backend state rm module.state
    ```

1. Delete the `infra/state-backend` directory.

1. In the Scaleway console, delete the reader and writer API keys, empty the bucket, then delete the bucket, applications, policies and project.
