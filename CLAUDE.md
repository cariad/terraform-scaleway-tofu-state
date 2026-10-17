# CLAUDE.md

An OpenTofu module (not Terraform) that creates a Scaleway project, a bucket and *reader* and *writer* IAM applications for keeping OpenTofu state.

## Commands

```bash
mise install                                             # Install the pinned tools
mise run lint                                            # Every linter, stopping at the first failure
mise run test                                            # tofu test with a mock provider (runs lint:tofu first to initialise)
mise exec -- tofu test -filter=tests/workload.tftest.hcl # One test file
mise exec -- tofu fmt -recursive                         # Fix OpenTofu formatting
mise exec -- tombi format .                              # Fix TOML formatting
```

CI runs each `lint:*` task as its own step, then `mise run --skip-deps test`, so a new linter also needs a step in `.github/workflows/ci.yml`.

## Keep in sync

- `.config/mise.toml`•`min_version` ↔ `.github/workflows/ci.yml`'s mise-action `version` ↔ the mise schema URL in `.config/tombi.toml`.
- `.config/mise.toml`•`tools`•`rumdl` ↔ the rumdl schema URL in `.config/tombi.toml`.
- After changing `[tools]`, run `mise lock`, because CI sets `MISE_LOCKED=1`.
- `.terraform.lock.hcl` is committed, and `lint:tofu` initialises with `-lockfile=readonly`. Update it with `tofu init -backend=false -upgrade`.
- The README's example `versions.tofu` pins the provider to its lower bound in `versions.tofu` (`~> 2.83.1`), and OpenTofu to `~> 1.12.0`. Don't raise that OpenTofu floor above the version Dependabot's `opentofu` updater bundles (1.12.1), or callers' Dependabot updates fail.
- `variables.tf` ↔ the README's `main.tf` usage step. There's no inputs table.
- The four test files each repeat the same `mock_provider` and `variables` blocks, because OpenTofu has no shared mocks.
- The `*_57_characters` test runs are 64 minus the 7-character `-reader` and `-writer` suffixes.

## Decisions not to undo

- The OpenTofu version constraint is a `language { compatible_with { opentofu = ... } }` block, not the legacy `required_version`. It lives in `versions.tofu` because Terraform, and tools that read only `.tf` files, fail on it in a `.tf` file. Providers stay in `terraform { required_providers }`, as a range, not a pin.
- The lower bounds in `versions.tofu` aren't tested. Before using a newer OpenTofu or provider feature, check that the lower bound has it, or raise the bound in a release.
- The bucket has its own Scaleway project, because Scaleway scopes Object Storage access by project. Both policies are limited to it with `project_ids`.
- There are no API key resources, because OpenTofu would store their secrets in state.
- The reader can only read objects, because plans run with `-lock=false`. The writer needs `ObjectStorageObjectsDelete`, because releasing the lock deletes the lock file.
- Changing `bucket` or `region` replaces the bucket, which `prevent_destroy` blocks, so treat either as a breaking change. For the same reason, never change `region`'s `fr-par` default.
- `bucket` forbids dots. The name goes into the hostname `<bucket>.s3.<region>.scw.cloud`, and the TLS certificate's wildcard covers only one label.
- `workload` forbids spaces. Scaleway's published rules allow them, but its console has said otherwise.
- `region` is checked against the same pattern as Scaleway's Go SDK, not a list, so a new region doesn't need a release.
- `workload` is the Scaleway project's name, the base of the IAM names in `locals.tf`, and part of every description. There's deliberately no separate display name. Preconditions in `iam.tf` check the IAM names against Scaleway's 64-character limit.
- The module has no outputs, because nothing needs them yet.

## Conventions

- Within a block, arguments are sorted alphabetically, then nested blocks follow. Variables and list items are sorted too.
- Variables are `nullable = false` with no default, except `region`.
- Comments briefly explain *why*.
- Validation error messages spell out the rule, because a failure shows the caller's argument, not the condition. Precondition messages stay short, because a failure shows the condition.
- Say "the Scaleway project" or "the workload" wherever "project" alone would be ambiguous.
- Tests mock project and application IDs as UUIDs, because the provider validates them even under a mock.
- Use British spelling.
- There's no `CHANGELOG.md`. `CONTRIBUTING.md` describes releasing.
