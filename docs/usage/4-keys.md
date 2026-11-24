# 4. Make backend API keys

Log into [Scaleway](https://www.scaleway.com), then open the [IAM / Applications](https://console.scaleway.com/iam/applications) console.

You should see two applications: `<workload>-reader` and `<workload>-writer`, where `workload` is the value you set in [`main.tf`](1-add.md#12-create-maintf).

!!! warning "Access denied"

    New policies can take a few minutes to take effect in Scaleway.

    If any of the following steps gives an "access denied" error, wait a few minutes before trying again.

For each application:

1. **Click to open the application**

1. **Open its "API keys" page**

1. **Click "Generate an API key"**

    Choose any expiration date you want.

    When you're asked if the key will be used for Object Storage, answer "Yes" and select the project that contains the bucket.

1. **Copy and securely store the access and secret keys**
