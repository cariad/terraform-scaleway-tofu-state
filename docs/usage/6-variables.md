# 6. Set environment variables for deployments

Wherever you perform OpenTofu plans, set the *reader* API key pair as the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

The *reader* is read-only, so run with `-lock=false` to prevent locking.

!!! warning "Your infrastructure module path"

    If your infrastructure module isn't in `infra/website` then be sure you update the `-chdir=` path before you run the command.

```shell
tofu -chdir=infra/website plan -lock=false
```

Wherever you perform OpenTofu deployments, set the *writer* API key pair as the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.

!!! warning "Your infrastructure module path"

    If your infrastructure module isn't in `infra/website` then be sure you update the `-chdir=` path before you run the command.

```shell
tofu -chdir=infra/website apply
```

…and you're done!
