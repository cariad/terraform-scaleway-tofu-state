# Contributing

## AI policy

AI-assisted contributions are welcomed.

## Required tools

- [mise](https://mise.jdx.dev/)

## Initial setup

1. Clone this repository.

   ```bash
   git clone git@github.com:cariad/terraform-scaleway-tofu-state.git
   ```

1. Change into the repository's directory.

   ```bash
   cd terraform-scaleway-tofu-state
   ```

1. Install the project's tools.

   ```bash
   mise install
   ```

1. To verify the setup, run the linters and tests and check they all pass.

   The tests use a mock provider, so they need no Scaleway credentials.

   ```bash
   mise run lint
   mise run test
   ```

## Releasing

1. Update the `ref` in the README's usage example to the new release's tag, and merge that change into `main`.
1. Publish a GitHub release for `main`.
