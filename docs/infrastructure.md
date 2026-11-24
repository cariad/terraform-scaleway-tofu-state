# What does it deploy?

In your [Scaleway](https://www.scaleway.com/) account, the `cariad/terraform-scaleway-tofu-state` module creates:

- **A Scaleway project**

    Groups the module's resources together.

- **A versioned, encrypted bucket**

    Holds the state and its most recent versions, in case you ever need to roll back.

- **A *reader* application and policy**

    Owns the API key that you'll create to run `tofu plan` with, which *can only read the state*.

- **A *writer* application and policy**

    Owns the API key that you'll create to run `tofu apply` with, which *can read, write, lock, and unlock the state*.

The module doesn't create the API keys themselves, because OpenTofu would store their secrets in the state backend's own state. You'll [make the API keys](usage/4-keys.md) yourself after you deploy the module.
