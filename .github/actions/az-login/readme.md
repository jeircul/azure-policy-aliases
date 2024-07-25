# az-login GitHub Action

Last revision: Jul 25th by [ovea](ovea@equinor.com).

This action logs into Azure PowerShell using Open ID Connect and Federated Credentials.
It also supports Azure CLI with the `enable-cli` option.

## Prerequisites

- Az.Accounts module should be installed.
  The action will install it if it does not exist.

## Inputs

- `client-id`: The Client ID of the identity to federate. This is a required input.
- `tenant-id`: The Tenant ID of the identity to federate. This is a required input.
- `enable-cli`: If set to true, the action will also log into Azure CLI.
  This is optional and defaults to false.

## Outputs

This action does not produce any outputs.

## How it works

1. Gets the URL for token exchange.
2. Gets the federated token from environment variables.
3. Invokes a web request to retrieve the JWT token.
4. Uses `Connect-AzAccount` to perform the authentication.

## How to use

```yaml
- name: Login
  uses: ./.github/actions/az-login
  with:
    client-id: ${{ secrets.CLIENT_ID }}
    tenant-id: ${{ vars.TENANT_ID }}
    enable-cli: true # Optional, defaults to false
```
