# codex-gemini-orchestrator

這個專案解決的主要痛點是：**讓 `AGENTS.md` 能根據模型能力與成本，把任務委派給合適的子代理；其中包含透過官方 Antigravity CLI 使用 Gemini 模型，並沿用既有訂閱登入狀態，不需要 Gemini API Key 計費方案。**

Codex 負責拆解任務、整合、審查與最終驗收；Gemini 子代理只執行範圍明確、可驗證的單次任務。

## 版本

- `versions/5.6-gemini3.6flash/`：目前版本，使用 Gemini 3.6 Flash 與 Gemini 3.1 Pro。
- `versions/5.6-gemini3.5flash/`：已廢棄，僅保留作為版本紀錄。
- `versions/5.6/`：早期 GPT-5.6 多模型路由基準。

目前版本包含：

```text
versions/5.6-gemini3.6flash/
├─ AGENTS.md
└─ scripts/
   └─ Invoke-AntigravityAgent.ps1
```

## 需求

- Windows 10 或 Windows 11
- PowerShell 7 (`pwsh`)
- Git
- Codex CLI
- 官方 Antigravity CLI（`agy`），且已登入可使用 Gemini 模型的訂閱帳號

不需要 Gemini API Key，也不要把憑證、Token 或 API Key 寫入設定、任務契約或版本庫。

## 安裝目前版本

先備份既有的 `$HOME\.codex\AGENTS.md` 與封裝腳本，再從專案根目錄執行：

```powershell
$sourceRoot = ".\versions\5.6-gemini3.6flash"
$codexRoot = "$HOME\.codex"

New-Item -ItemType Directory -Path "$codexRoot\scripts" -Force | Out-Null
Copy-Item -LiteralPath "$sourceRoot\AGENTS.md" -Destination "$codexRoot\AGENTS.md" -Force
Copy-Item -LiteralPath "$sourceRoot\scripts\Invoke-AntigravityAgent.ps1" `
    -Destination "$codexRoot\scripts\Invoke-AntigravityAgent.ps1" -Force
```

`AGENTS.md` 會使用以下穩定 alias：

- `gemini-3.6-flash` → `gemini-3.6-flash-high`
- `gemini-3.1-pro` → `gemini-3.1-pro-high`

封裝腳本會用 `agy models` 驗證 alias，並透過已登入的 Antigravity 訂閱工作階段執行單次、無狀態任務。

## 解除腳本的下載來源標記

從 GitHub 下載 ZIP，或重新複製帶有 Mark of the Web 的腳本時，新檔案可能再次附帶 `Zone.Identifier`，導致 PowerShell 在 `RemoteSigned` 政策下拒絕執行。每次重新下載或複製後都應重新檢查。

先檢查標記：

```powershell
$scriptPath = "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1"

Get-Item -LiteralPath $scriptPath |
    Get-Item -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

若有輸出，解除標記：

```powershell
Unblock-File -LiteralPath $scriptPath
```

再次確認：

```powershell
Get-Item -LiteralPath $scriptPath |
    Get-Item -Stream Zone.Identifier -ErrorAction SilentlyContinue
```

沒有輸出即代表標記已移除。

## 使用方式

先準備隔離的 Git worktree 與完整 UTF-8 任務契約，再呼叫：

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" `
    -WorkingDirectory "C:\path\to\isolated-worktree" `
    -Model gemini-3.6-flash `
    -PromptFile "C:\path\to\task-contract.md" `
    -AutoApprove
```

只有在任務契約允許指定範圍內的本機寫入時才使用 `-AutoApprove`。Gemini 不應提交、合併、推送、發布或部署；Codex 必須審查輸出並完成最終驗收。

## 授權與貢獻

本專案採用 [MIT License](LICENSE)。提交變更前請閱讀 [CONTRIBUTING.md](CONTRIBUTING.md)，安全性問題請參閱 [SECURITY.md](SECURITY.md)。
