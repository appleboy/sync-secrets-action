# Gitea 同步 Secrets Action

[English](README.md) | [繁體中文](README_zh-TW.md) | [简体中文](README_zh-CN.md)

[![GitHub Release](https://img.shields.io/github/release/appleboy/sync-secrets-action.svg)](https://github.com/appleboy/sync-secrets-action/releases)

一个 GitHub Action，可自动将 secrets 从一个仓库同步到 Gitea 中的多个仓库或组织。此 action 帮助您在多个项目之间保持一致的 secrets，无需手动操作。

## 功能特色

- 🔄 同步 secrets 到多个仓库
- 🏢 同步 secrets 到整个组织
- 🔐 支持环境特定的 secrets
- 🧪 测试用的干运行模式
- ✅ SSL 验证控制
- 📝 同步操作的自定义描述

## 使用方法

### 基本示例

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

### 同步到组织

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
    description: "生产环境每周 secrets 同步"
```

### 环境特定的 Secrets

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

### 干运行模式

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

### 使用调试日志

```yaml
- name: Sync secrets with debug logging
  uses: appleboy/sync-

secrets-action@v1
  env:
    API_KEY: ${{ secrets.API_KEY }}
  with:
    gitea_server: https://gitea.example.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    repos: |
      user/repo1
    secrets: |
      API_KEY
    debug: true
```

## 输入参数

| 输入 | 描述 | 必须 | 默认值 |
|-------|-------------|----------|---------|
| `gitea_token` | 用于获取仓库和写入 secrets 的令牌。必须具有适当的权限。 | ✅ | |
| `gitea_server` | 要使用的 Gitea 服务器 URL（例如：`https://gitea.example.com`）。 | ✅ | |
| `repos` | 要复制 secrets 的仓库列表，换行分隔（格式：`owner/repo`）。 | ❌ | |
| `orgs` | 要复制 secrets 的组织列表，换行分隔。 | ❌ | |
| `gitea_skip_verify` | 发出 Gitea API 请求时跳过 SSL 验证。设为 `true` 以禁用 SSL 验证。 | ❌ | `false` |
| `secrets` | 从环境变量中选择值的 secret 名称列表，换行分隔。使用 action env 从仓库传递 secrets。 | ✅ | |
| `dry_run` | 执行除了 secret 创建和更新功能之外的所有操作。适用于测试。 | ❌ | `false` |
| `environment` | 如果设定，action 将把 secrets 设置到具有此名称的仓库环境中。仅适用于 Actions secrets。 | ❌ | `` |
| `description` | 同步操作的可选描述，用于帮助识别此 secrets 同步的目的。 | ❌ | |
| `debug` | 启用调试模式以输出详细的日志信息用于故障排除。 | ❌ | `false` |

## 需求

- 具有 API 访问权限的 Gitea 服务器
- 具有适当权限的 Gitea 令牌：
  - 目标仓库的仓库访问权限
  - 目标组织的组织访问权限
  - 读取和写入 secrets 的权限

## 令牌权限

`gitea_token` 必须具有以下权限：

- **仓库权限**：目标仓库的读取访问权限
- **Actions secrets**：管理仓库 secrets 的写入访问权限
- **组织权限**：目标组织的读取访问权限（如果同步到组织）

您可以在 Gitea 实例中的 **设置** → **应用程序** → **生成新令牌** 下创建令牌。

## Secret 模式

`secrets` 输入接受换行分隔的确切 secret 名称以匹配环境变量：

```yaml
secrets: |
  DATABASE_URL
  DATABASE_PASSWORD
  API_KEY
  PROD_API_KEY
  PROD_DB_PASSWORD
  GITHUB_TOKEN
```

## 环境变量

请确保在工作流程中将您想要同步的 secrets 作为环境变量传递：

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_

KEY: ${{ secrets.API_KEY }}
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## 错误处理

此 action 将：

- 跳过不存在或无法访问的仓库
- 对无法同步的 secrets 记录警告
- 即使某些仓库失败，仍会继续处理其余仓库
- 在 action 日志中提供详细的错误消息

## 安全考虑

- **令牌安全**：将您的 Gitea 令牌存储为 GitHub secret
- **Secret 暴露**：Secrets 会安全地传输到 Gitea API
- **审计跟踪**：所有 secret 操作都会在 action 输出中记录
- **SSL 验证**：除非绝对必要，否则请保持 `gitea_skip_verify` 为 `false`

## 高级示例

### 同步特定 Secrets 到多个仓库

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
    description: "同步 CI/CD 部署 secrets"
```

### 组织级 Secret 管理

```yaml
- name: Sync organization secrets
  uses: appleboy/sync-secrets-action@v1
  env:
    SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
    SLACK_WEBHOOK: ${{ secrets.SLACK_WEBHOOK }}
    MONITORING_API_KEY: ${{ secrets.MONITORING_API_KEY }}
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
    description: "每月组织级 secret 同步"
```

### 跳过 SSL 验证（不推荐）

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
    description: "使用自签证书的内部测试"
```

## 故障排除

### 常见问题

1. **权限被拒绝**：确保您的

`gitea_token` 具有必要权限
2. **找不到仓库**：检查仓库名称是否正确且可访问
3. **SSL 证书问题**：仅在内部/测试环境中使用 `gitea_skip_verify: true`
4. **找不到 Secret**：验证 secrets 是否在工作流程环境中正确定义

### 调试模式

使用 `debug` 参数启用详细的调试日志：

```yaml
- name: Sync with debug logging
  uses: appleboy/sync-secrets-action@v1
  with:
    gitea_server: https://gitea.example.com
    gitea_token: ${{ secrets.GITEA_TOKEN }}
    repos: |
      user/repo1
    secrets: |
      API_KEY
    debug: true
```

您也可以通过在仓库中将 `ACTIONS_STEP_DEBUG` secret 设为 `true` 来启用 GitHub Actions 调试日志：

```yaml
- name: Enable GitHub Actions debug logging
  env:
    ACTIONS_STEP_DEBUG: true
```

## 贡献

欢迎贡献！请随时提交 Pull Request。对于重大更改，请先开启 issue 讨论您想要更改的内容。

1. Fork 此仓库
2. 创建您的功能分支（`git checkout -b feature/amazing-feature`）
3. 提交您的更改（`git commit -m 'Add some amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 开启 Pull Request

## 许可证

此项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

## 作者

由 [Bo-Yi Wu](https://github.com/appleboy) 创建和维护。

## 相关项目

- [gitea-secret-sync](https://github.com/appleboy/gitea-secret-sync) - 底层 CLI 工具
- [drone-gitea-secret-sync](https://github.com/appleboy/drone-gitea-secret-sync) - Drone CI 插件版本

## 支持

如果您有任何问题或需要帮助，请：

1. 检查 [Issues](https://github.com/appleboy/sync-secrets-action/issues) 寻找现有解决方案
2. 创建新 issue 并详细描述您的问题
3. 在我们的 [Discussions](https://github.com/appleboy/sync-secrets-action/discussions) 区域加入讨论
