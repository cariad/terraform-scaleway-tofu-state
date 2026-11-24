# 2. Get a temporary Scaleway API key

Log into [Scaleway](https://www.scaleway.com/) and [generate a personal API key](https://console.scaleway.com/iam/api-keys).

- Have the key expire in an hour — we're only going to use it once, then we'll destroy it.

- When Scaleway asks if the key will be used for Object Storage, say *no*.

Set the API key pair and your Scaleway organisation's ID as environment variables in a local shell:

```shell
export SCW_ACCESS_KEY="..."
export SCW_SECRET_KEY="..."
export SCW_DEFAULT_ORGANIZATION_ID="..."
```

!!! info "Organisation ID"

    Your organisation ID is a UUIDv4 in the format `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`, which should be visible on your [API keys](https://console.scaleway.com/iam/api-keys) page.
