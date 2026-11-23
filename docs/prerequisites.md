# What do I need?

- **Your own [Scaleway] account**

    You must provision this yourself, and you're responsible for your own charges.

    !!! tip "Your project isn't tied to Scaleway"

        Remember, the `cariad/terraform-scaleway-tofu-state` module sets up OpenTofu state storage in Scaleway, but the rest of your infrastructure can be deployed to [bunny.net], [AWS], or any other supported provider.

- **[OpenTofu](https://opentofu.org) 1.13 or later**

[AWS]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

[bunny.net]: https://registry.terraform.io/providers/BunnyWay/bunnynet/latest/docs

[Scaleway]: https://www.scaleway.com
