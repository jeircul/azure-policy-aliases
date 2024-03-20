# az-login github action

Last revision: Feb 14th by [ovea](ovea@equinor.com).
Login to PowerShell with the use of Open ID Connect and Federated Credentials.
Azure CLI is also supported with `enable-cli` option.

## How it works

1. Gets the URL for token exchange,

2. Gets the federated token from environment variables,

3. Invokes web request to retrieve JWT token,

4. Uses Connect-AzAccount to perform the authentication.

## How to use

```yaml
  - name: Login
    uses: ./.github/actions/az-login
    with:
      client-id: ${{ secrets.CLIENT_ID }}
      tenant-id: ${{ vars.TENANT_ID }}
      enable-cli: true # Optional, defaults to false
```

## Limitiations

- Need Az.Accounts to be used (action will install if it does not exist).
