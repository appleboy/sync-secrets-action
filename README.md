# Gitea Sync Secrets Action

[![GitHub Release](https://img.shields.io/github/release/appleboy/sync-secrets-action.svg)](https://github.com/appleboy/sync-secrets-action/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/appleboy/gitea-secret-sync.svg)](https://hub.docker.com/r/appleboy/gitea-secret-sync/)

A GitHub Action that automatically synchronizes secrets from one repository to multiple repositories or organizations in Gitea. This action helps you maintain consistent secrets across multiple projects without manual intervention.

## Features

- 🔄 Sync secrets to multiple repositories
- 🏢 Sync secrets to entire organizations
- 🔐 Support for environment-specific secrets
- 🧪 Dry run mode for testing
- ✅ SSL verification control
- 📝 Custom descriptions for sync operations

## Usage

### Basic Example

```yaml
name: Sync Secrets
on:
  workflow_dispatch:
  push:
    branches:
      - main

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync secrets to repositories
        uses: appleboy/sync-secrets-action@v1
        env:
          DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
          DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
          API_KEY: ${{ secrets.API_KEY }}
        with:
          gitea_server: https://gitea.example.com
          gitea_token: ${{ secrets.GITEA_TOKEN }}
          repos: |
            user/repo1
            user/repo2
            org/repo3
          secrets: |
            DOCKER_USERNAME
            DOCKER_PASSWORD
            API_KEY
```

### Sync to Organizations

```yaml
- name: Sync secrets to organizations
  uses: appleboy/sync-secrets-action@v1
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    REDIS_URL: ${{ secrets.REDIS_URL }}
  with:
    gitea_server: https://gitea.example.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    orgs: |
      my-organization
      another-org
    secrets: |
      DATABASE_URL
      REDIS_URL
    description: "Weekly secrets sync for production environments"
```

### Environment-Specific Secrets

```yaml
- name: Sync secrets to specific environment
  uses: appleboy/sync-secrets-action@v1
  env:
    PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
    PROD_DB_PASSWORD: ${{ secrets.PROD_DB_PASSWORD }}
  with:
    gitea_server: https://gitea.example.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    repos: |
      company/web-app
      company/api-service
    secrets: |
      PROD_API_KEY
      PROD_DB_PASSWORD
    environment: production
```

### Dry Run Mode

```yaml
- name: Test secret sync (dry run)
  uses: appleboy/sync-secrets-action@v1
  env:
    TEST_SECRET: ${{ secrets.TEST_SECRET }}
  with:
    gitea_server: https://gitea.example.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    repos: |
      user/test-repo
    secrets: |
      TEST_SECRET
    dry_run: true
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `gitea_token` | Token to use to get repositories and write secrets. Must have appropriate permissions. | ✅ | |
| `gitea_server` | The URL of the Gitea server to use (e.g., `https://gitea.example.com`). | ✅ | |
owner/repo`). | ❌ | |
| `orgs` | Newline-delimited list of organizations to copy secrets to. | ❌ | |
| `gitea_skip_verify` | Skip SSL verification when making requests to the Gitea API. Set to `true` to disable SSL verification. | ❌ | `false` |
| `secrets` | Newline-delimited list of secret names to select values from environment variables. Use the action env to pass secrets from the repository. | ✅ | |
| `dry_run` | Run everything except for secret create and update functionality. Useful for testing. | ❌ | `false` |
| `environment` | If set, the action will set the secrets to the repositories' environment with this name. Only works for Actions secrets. | ❌ | |
| `description` | Optional description for the sync operation to help identify the purpose of this secrets synchronization. | ❌ | |

## Requirements

- A Gitea server with API access
- A Gitea token with appropriate permissions:
  - Repository access for target repositories
  - Organization access for target organizations
  - Permission to read and write secrets

## Token Permissions

The `gitea_token` must have the following permissions:

- **Repository permissions**: Read access to target repositories
- **Actions secrets**: Write access to manage repository secrets
- **Organization permissions**: Read access to target organizations (if syncing to orgs)

You can create a token in your Gitea instance under **Settings** → **Applications** → **Generate New Token**.

## Secret Patterns

The `secrets` input accepts newline-delimited exact secret names to match environment variables:

```yaml
secrets: |
  DATABASE_URL
  DATABASE_PASSWORD
  API_KEY
  PROD_API_KEY
  PROD_DB_PASSWORD
  GITHUB_TOKEN
```

## Environment Variables

Make sure to pass the secrets you want to sync as environment variables in your workflow:

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## Error Handling

The action will:

- Skip repositories that don't exist or are inaccessible
- Log warnings for secrets that can't be synced
- Continue processing remaining repositories even if some fail
- Provide detailed error messages in the action logs

## Security Considerations

- **Token Security**: Store your Gitea token as a GitHub secret
- **Secret Exposure**: Secrets are transmitted securely to the Gitea API
- **Audit Trail**: All secret operations are logged in the action output
- **SSL Verification**: Keep `gitea_skip_verify` as `false` unless absolutely necessary

## Advanced Examples

### Sync Specific Secrets to Multiple Repositories

```yaml
- name: Sync deployment secrets
  uses: appleboy/sync-secrets-action@v1
  env:
    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  with:
    gitea_server: https://git.company.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    repos: |
      company/frontend
      company/backend
      company/mobile-app
    secrets: |
      DEPLOY_KEY
      AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY
    description: "Sync deployment secrets for CI/CD"
```

### Organization-wide Secret Management

```yaml
- name: Sync organization secrets
  uses: appleboy/sync-secrets-action@v1
  env:
    SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
    MONITORING_API_KEY: ${{ secrets.MONITORING_API
| `repos` | Newline-delimited list of repositories to copy secrets to (format: `

_KEY }}
  with:
    gitea_server: https://git.company.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    orgs: |
      engineering
      devops
      qa
    secrets: |
      SENTRY_DSN
      SLACK_WEBHOOK
      MONITORING_API_KEY
    environment: production
    description: "Monthly organization-wide secret sync"
```

### Skip SSL Verification (Not Recommended)

```yaml
- name: Sync secrets with SSL skip
  uses: appleboy/sync-secrets-action@v1
  env:
    TEST_SECRET: ${{ secrets.TEST_SECRET }}
  with:
    gitea_server: https://internal-gitea.company.local
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    gitea_skip_verify: true
    repos: |
      internal/test-repo
    secrets: |
      TEST_SECRET
    description: "Internal testing with self-signed certificates"
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure your `gitea_token` has the necessary permissions
2. **Repository Not Found**: Check that repository names are correct and accessible
3. **SSL Certificate Issues**: Use `gitea_skip_verify: true` only for internal/testing environments
4. **Secret Not Found**: Verify that secrets are properly defined in the workflow environment

### Debug Mode

Enable debug logging by setting the `ACTIONS_STEP_DEBUG` secret to `true` in your repository:

```yaml
- name: Enable debug logging
  env:
    ACTIONS_STEP_DEBUG: true
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

Created and maintained by [Bo-Yi Wu](https://github.com/appleboy).

## Related Projects

- [gitea-secret-sync](https://github.com/appleboy/gitea-secret-sync) - The underlying CLI tool
- [drone-gitea-secret-sync](https://github.com/appleboy/drone-gitea-secret-sync) - Drone CI plugin version

## Support

If you have any questions or need help, please:

1. Check the [Issues](https://github.com/appleboy/sync-secrets-action/issues) for existing solutions
2. Create a new issue with detailed information about your problem
3. Join the discussion in our [Discussions](https://github.com/appleboy/sync-secrets-action/discussions) section
