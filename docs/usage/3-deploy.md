# 3. Deploy the backend

## 3.1. Initialise the state-backend module

!!! warning "Your state-backend module path"

    If you didn't put your state-backend module in `infra/state-backend` then be sure you update the `-chdir=` path before you run the command.

Run `tofu` to initialise the state-backend module:

```shell
tofu -chdir=infra/state-backend init
```

If it succeeds, then you should see a message like:

```text
OpenTofu has been successfully initialized!
```

## 3.2. Review and apply the deployment

!!! warning "Your state-backend module path"

    If you didn't put your state-backend module in `infra/state-backend` then be sure you update the `-chdir=` path before you run the command.

Run `tofu` to review then deploy the state-backend module:

```shell
tofu -chdir=infra/state-backend apply
```

If it succeeds, then you should see a message like:

```text
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

## 3.3. Revoke your temporary API key

You don't need your one-hour API key any more, so delete it from [the API keys console](https://console.scaleway.com/iam/api-keys).

## 3.4. Backup the state-backend module state

The deployment will have created a `terraform.tfstate` file in your state-backend module directory. Backup that file somewhere private, because you'll need it to update this infrastructure in the future.
