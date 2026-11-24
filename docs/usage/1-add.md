# 1. Add the backend module

## 1.1. Create the module directory

Create a new "state-backend" module directory, alongside your own infrastructure.

For example, if you describe your project's infrastructure within an "infra" directory, then create the new "state-backend" directory in there.

```text
your-repository/
└─ infra/
    ├─ state-backend/ *
    └─ website/
```

!!! info "You don't have to call it "state-backend""

    This guide will refer to the new module as "state-backend", but you can name it anything you like.

## 1.2. Create `main.tf`

Create `main.tf` inside the new module directory.

```text
your-repository/
└─ infra/
    └─ state-backend/
       └─ main.tf *
```

Copy and paste this template into the file, then fill in the `bucket`, `workload`, and optional `region`:

```hcl
{%+ include "main.tf" %}
```

!!! danger "Choose the bucket name and region carefully"

    Neither the bucket name nor region can be changed after their initial deployment. Changing either of these will cause Scaleway to try to destroy and recreate the bucket, which will fail because this module applies deletion protection.

## 1.3. Ignore the module's state and working files

Add these entries to your `.gitignore`:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
```
