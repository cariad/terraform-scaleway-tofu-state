# 2. Deploy the backend

## 2.1. Generate a temporary Scaleway API key

Log into [Scaleway](https://www.scaleway.com/) and [generate a personal API key](https://console.scaleway.com/iam/api-keys).

Have the key expire in an hour — we're only going to use it once, then we'll destroy it.

When Scaleway asks if the key will be used for Object Storage, say *no*.

## 2.2. Set temporary environment variables

Set the API key pair and your Scaleway organisation's ID as environment variables in a local shell:

```bash
export SCW_ACCESS_KEY="..."
export SCW_SECRET_KEY="..."
export SCW_DEFAULT_ORGANIZATION_ID="..."
```

!!! info "Organisation ID"

    Your organisation ID is a UUIDv4 in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, which should be visible on your [API keys](https://console.scaleway.com/iam/api-keys) page.

## 2.3. Initialise the state-backend module

!!! warning "Your state-backend module path"

    If you didn't put your state-backend module in `infra/state-backend` then be sure you update the `-chdir=` path before you run the command.

Run `tofu` to initialise the state-backend module:

```bash
tofu -chdir=infra/state-backend init
```

If it succeeds, then you should see a message like:

```text
OpenTofu has been successfully initialized!
```

## 2.4. Review and apply the deployment

!!! warning "Your state-backend module path"

    If you didn't put your state-backend module in `infra/state-backend` then be sure you update the `-chdir=` path before you run the command.

Run `tofu` to review then deploy the state-backend module:

```bash
tofu -chdir=infra/state-backend apply
```

If it succeeds, then you should see a message like:

```text
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
```

## 2.5. Revoke your temporary API key

You don't need your one-hour API key any more, so delete it from [the API keys console](https://console.scaleway.com/iam/api-keys).

## 2.6. Backup the state-backend module state

The deployment will have created a `terraform.tfstate` file in your state-backend module directory. Backup that file somewhere private, because you'll need it to update this infrastructure in the future.

With that done, the state-backend is deployed! Now you can [make API keys to access the new bucket](3-keys.md).
