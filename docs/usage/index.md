# How do I deploy it?

The deployment breaks down into five steps:

1. **[Add the backend module](1-add.md)**

    Adds the `cariad/terraform-scaleway-tofu-state` to your project.

1. **[Deploy the backend](2-deploy.md)**

    Deploys the `cariad/terraform-scaleway-tofu-state` module from your project.

1. **[Make backend API keys](3-keys.md)**

    Creates the access keys that `tofu` will need to read/write state to/from your new bucket.

1. **[Point your infrastructure at the backend](4-use.md)**

    Updates your infrastructure to keep its state in the new bucket.

1. **[Set environment variables for deployments](5-variables.md)**

    Sets the bucket's access keys as environment variables for your deployments to use.
