# How do I upgrade it?

Each release of the `cariad/terraform-scaleway-tofu-state` module is a GitHub release with an immutable tag, and its [release notes](https://github.com/cariad/terraform-scaleway-tofu-state/releases) describe what changed.

To upgrade your infrastructure to a later release:

1. Update the `source` in your `main.tf` to the latest release, and keep your existing configuration:

    ```hcl
    {%+ filter indent(4) %}{%+ include "main.tf" %}{% endfilter %}
    ```

    !!! danger "Don't change the bucket name or region"

        Neither the bucket name nor region can be changed after their initial deployment. Changing either of these will cause Scaleway to try to destroy and recreate the bucket, which will fail because this module applies deletion protection.

1. Restore your backed-up `terraform.tfstate` into the module directory.
1. Follow [Get a temporary Scaleway API key](usage/2-scaleway-key.md), then come back here.
1. Download the new versions:

    !!! warning "Your state-backend module path"

        If you didn't put your state-backend module in `infra/state-backend` then be sure you update the `-chdir=` path before you run the command.

    ```shell
    tofu -chdir=infra/state-backend init -upgrade
    ```

1. Review the changes:

    ```shell
    tofu -chdir=infra/state-backend plan
    ```

1. Apply the changes:

    ```shell
    tofu -chdir=infra/state-backend apply
    ```

1. Revoke your temporary API key in [the API keys console](https://console.scaleway.com/iam/api-keys).
1. Back up the updated `terraform.tfstate` somewhere private.

## Upgrading with Dependabot

Dependabot's `opentofu` ecosystem can open pull requests to upgrade the module. It names a Git module `<module label>::github::<owner>/<repo>::<ref>`, so an `allow` rule that limits it to this module needs wildcards:

```yaml
version: 2

updates:
  - allow:
      - dependency-name: "*::github::cariad/terraform-scaleway-tofu-state::*"
    directories:
      - /infra/state-backend
    package-ecosystem: opentofu
    schedule:
      interval: weekly
```
