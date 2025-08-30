# Gitea 同步 Secrets Action

[English](README.md) | [繁體中文](README_zh-TW.md) | [简体中文](README_zh-CN.md)

[![GitHub Release](https://img.shields.io/github/release/appleboy/sync-secrets-action.svg)](https://github.com/appleboy/sync-secrets-action/releases)

一個 GitHub Action，可自動將 secrets 從一個存儲庫同步到 Gitea 中的多個存儲庫或組織。此 action 幫助您在多個專案之間保持一致的 secrets，無需手動操作。

## 功能特色

- 🔄 同步 secrets 到多個存儲庫
- 🏢 同步 secrets 到整個組織
- 🔐 支援環境特定的 secrets
- 🧪 測試用的乾執行模式
- ✅ SSL 驗證控制
- 📝 同步操作的自定義描述

## 使用方法

### 基本範例

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

### 同步到組織

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
    description: "生產環境每週 secrets 同步"
```

### 環境特定的 Secrets

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

### 乾執行模式

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

### 使用調試日

志

```yaml
- name: Sync secrets with debug logging
  uses: appleboy/sync-secrets-action@v1
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

## 輸入參數

| 輸入 | 描述 | 必須 | 預設值 |
|-------|-------------|----------|---------|
| `gitea_token` | 用於獲取存儲庫和寫入 secrets 的令牌。必須具有適當的權限。 | ✅ | |
| `gitea_server` | 要使用的 Gitea 伺服器 URL（例如：`https://gitea.example.com`）。 | ✅ | |
| `repos` | 要複製 secrets 的存儲庫清單，換行分隔（格式：`owner/repo`）。 | ❌ | |
| `orgs` | 要複製 secrets 的組織清單，換行分隔。 | ❌ | |
| `gitea_skip_verify` | 發出 Gitea API 請求時跳過 SSL 驗證。設為 `true` 以停用 SSL 驗證。 | ❌ | `false` |
| `secrets` | 從環境變數中選擇值的 secret 名稱清單，換行分隔。使用 action env 從存儲庫傳遞 secrets。 | ✅ | |
| `dry_run` | 執行除了 secret 建立和更新功能之外的所有操作。適用於測試。 | ❌ | `false` |
| `environment` | 如果設定，action 將把 secrets 設置到具有此名稱的存儲庫環境中。僅適用於 Actions secrets。 | ❌ | `` |
| `description` | 同步操作的可選描述，用於協助識別此 secrets 同步的目的。 | ❌ | |
| `debug` | 啟用調試模式以輸出詳細的日志資訊用於故障排除。 | ❌ | `false` |

## 需求

- 具有 API 訪問權限的 Gitea 伺服器
- 具有適當權限的 Gitea 令牌：
  - 目標存儲庫的存儲庫訪問權限
  - 目標組織的組織訪問權限
  - 讀取和寫入 secrets 的權限

## 令牌權限

`gitea_token` 必須具有以下權限：

- **存儲庫權限**：目標存儲庫的讀取訪問權限
- **Actions secrets**：管理存儲庫 secrets 的寫入訪問權限
- **組織權限**：目標組織的讀取訪問權限（如果同步到組織）

您可以在 Gitea 實例中的 **設定** → **應用程式** → **生成新令牌** 下建立令牌。

## Secret 模式

`secrets` 輸入接受換行分隔的確切 secret 名稱以匹配環境變數：

```yaml
secrets: |
  DATABASE_URL
  DATABASE_PASSWORD
  API_KEY
  PROD_API_KEY
  PROD_DB

_PASSWORD
  GITHUB_TOKEN
```

## 環境變數

請確保在工作流程中將您想要同步的 secrets 作為環境變數傳遞：

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  API_KEY: ${{ secrets.API_KEY }}
  DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
  DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

## 錯誤處理

此 action 將：

- 跳過不存在或無法訪問的存儲庫
- 對無法同步的 secrets 記錄警告
- 即使某些存儲庫失敗，仍會繼續處理其餘存儲庫
- 在 action 日志中提供詳細的錯誤訊息

## 安全考量

- **令牌安全**：將您的 Gitea 令牌儲存為 GitHub secret
- **Secret 暴露**：Secrets 會安全地傳輸到 Gitea API
- **稽核軌跡**：所有 secret 操作都會在 action 輸出中記錄
- **SSL 驗證**：除非絕對必要，否則請保持 `gitea_skip_verify` 為 `false`

## 進階範例

### 同步特定 Secrets 到多個存儲庫

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

### 組織級 Secret 管理

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
    description: "每月組織級 secret 同步"
```

### 跳過 SSL 驗證（不建議）

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
    description: "使用自簽憑證的內部測試"
```

## 故障排除

### 常見問題

1. **權限被拒絕**：確保您的 `git

ea_token` 具有必要權限
2. **找不到存儲庫**：檢查存儲庫名稱是否正確且可訪問
3. **SSL 憑證問題**：僅在內部/測試環境中使用 `gitea_skip_verify: true`
4. **找不到 Secret**：驗證 secrets 是否在工作流程環境中正確定義

### 調試模式

使用 `debug` 參數啟用詳細的調試日志：

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

您也可以通過在存儲庫中將 `ACTIONS_STEP_DEBUG` secret 設為 `true` 來啟用 GitHub Actions 調試日志：

```yaml
- name: Enable GitHub Actions debug logging
  env:
    ACTIONS_STEP_DEBUG: true
```

## 貢獻

歡迎貢獻！請隨時提交 Pull Request。對於重大更改，請先開啟 issue 討論您想要更改的內容。

1. Fork 此存儲庫
2. 建立您的功能分支（`git checkout -b feature/amazing-feature`）
3. 提交您的更改（`git commit -m 'Add some amazing feature'`）
4. 推送到分支（`git push origin feature/amazing-feature`）
5. 開啟 Pull Request

## 授權

此專案採用 MIT 授權 - 詳見 [LICENSE](LICENSE) 檔案。

## 作者

由 [Bo-Yi Wu](https://github.com/appleboy) 建立和維護。

## 相關專案

- [gitea-secret-sync](https://github.com/appleboy/gitea-secret-sync) - 底層 CLI 工具
- [drone-gitea-secret-sync](https://github.com/appleboy/drone-gitea-secret-sync) - Drone CI 插件版本

## 支援

如果您有任何問題或需要協助，請：

1. 檢查 [Issues](https://github.com/appleboy/sync-secrets-action/issues) 尋找現有解決方案
2. 建立新 issue 並詳細描述您的問題
3. 在我們的 [Discussions](https://github.com/appleboy/sync-secrets-action/discussions) 區域加入討論
