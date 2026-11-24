# How do I deploy it?

The deployment breaks down into six steps:

1. **[Add the backend module](1-add.md)**

    Adds the `cariad/terraform-scaleway-tofu-state` module to your project.

1. **[Get a temporary Scaleway API key](2-scaleway-key.md)**

    Generates a short-lived Scaleway API key for the deployment to use.

1. **[Deploy the backend](3-deploy.md)**

    Deploys the `cariad/terraform-scaleway-tofu-state` module from your project.

1. **[Make backend API keys](4-keys.md)**

    Creates the access keys that `tofu` will need to read/write state to/from your new bucket.

1. **[Point your infrastructure at the backend](5-use.md)**

    Updates your infrastructure to keep its state in the new bucket.

1. **[Set environment variables for deployments](6-variables.md)**

    Sets the bucket's access keys as environment variables for your deployments to use.
