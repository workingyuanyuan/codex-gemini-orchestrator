# codex-gemini-orchestrator

> 目前版本透過已登入的 Antigravity CLI，僅委派給 Gemini 3.8 Flash High。

這個專案讓精簡的 `AGENTS.md` 按需載入委派技能，再透過官方 Antigravity CLI 將範圍明確的任務交給 Gemini 3.8 Flash High，沿用既有訂閱登入狀態。

Codex 負責架構、拆解、整合、審查與最終驗收；子代理只執行範圍明確、可客觀驗證的單次任務。

## 版本

- `versions/6-gemini3.8flash/`：目前版本，包含 Gemini 3.8 Flash High 唯一委派配置、技能與 Antigravity wrapper。
- `versions/5.6-gemini3.8flash/`：GPT-5.6 配置，包含 Routing Table、Terra／Luna 與 Gemini Medium／High 路由。
- `versions/5.6-gemini3.7flash/`：已封存，保留作為版本紀錄。
- `versions/5.6-gemini3.6flash/`：已廢棄，僅保留作為版本紀錄。
- `versions/5.6-gemini3.5flash/`：已廢棄，僅保留作為版本紀錄。
- `versions/5.6/`：早期 GPT-5.6 多模型路由基準。

目前版本包含：

```text
versions/6-gemini3.8flash/
├─ AGENTS.md
├─ scripts/
│  └─ Invoke-AntigravityAgent.ps1
└─ skills/
   └─ model-routing-and-delegation-agy/
      ├─ SKILL.md
      └─ agents/
         └─ openai.yaml
```

## 需求

- Windows 10 或 Windows 11
- PowerShell 7 (`pwsh`)
- Git
- Codex CLI
- 官方 Antigravity CLI（`agy`），且已登入可使用對應模型的訂閱帳號

不需要 API Key，也不要把憑證、Token 或 API Key 寫入設定、任務契約或版本庫。

## 安裝目前版本

從專案根目錄執行：

```powershell
./install.ps1 -Version 6-gemini3.8flash
```

安裝器會把 `AGENTS.md`、`scripts/` 與 `skills/`（有原生 profiles 的歷史版本也會安裝 `agents/`）複製到 `$HOME\.codex`。若已有同名檔案，安裝會列出衝突並中止；確認備份後可使用 `-Force` 只覆寫列出的檔案：

```powershell
./install.ps1 -Version 6-gemini3.8flash -Force
```

更新既有安裝也使用上述 `-Force` 指令。它會覆寫同名的本機客製檔案，因此請先備份；更新 skill 後請開啟新的 Codex task，讓新指令被重新載入。

## 任務委派

`AGENTS.md` 只定義委派時機與技能入口；模型限制、主代理職責及執行流程集中於 Skill。能節省時間或改善品質時，委派可獨立驗收的並行工作，主代理在等待期間繼續其他獨立工作。此觸發方式依據 [GPT-6 Astra 的 Subagent delegation 指引](https://developers.openai.com/api/docs/guides/latest-model?model=gpt-6-astra#subagent-delegation)，並依 Antigravity 的單層委派流程調整。

唯一入口為 `gemini-3.8-flash-high`，精確對應 `agy models` 中的同名 slug。所有委派均使用 Gemini 3.8 Flash High；合約、上下文或環境問題修正後重試一次，仍失敗或能力不足時交回主代理。

```powershell
& "$HOME\.codex\scripts\Invoke-AntigravityAgent.ps1" -WorkingDirectory $worktree -Model gemini-3.8-flash-high -PromptFile $contract -AutoApprove
```

安裝目的地可使用 `-DestinationRoot <path>` 指定。由舊版升級時，請備份本機規則與 profiles，並移除本專案先前安裝的 `gpt-5-6-luna-max.toml`、`gpt-5-6-terra-max.toml`。安裝器僅複製來源檔案；本機 AGENTS.md 的自訂段落應在覆寫前備份並於安裝後合併。
Antigravity 的 print mode 是 headless 執行，讀取程式碼所需的 command 權限也無法互動核准。因此所有 Antigravity 任務（包括唯讀審查）都必須在專用的 detached worktree 中搭配 `-AutoApprove`；唯讀限制寫進任務契約，完成後再驗證 worktree 沒有 diff。不要對主要 checkout 或共享的 dirty worktree 使用 `-AutoApprove`。wrapper 只在自己的程序及其子程序中信任指定 worktree，不會修改全域 Git 設定；空輸出或已知的 headless 權限拒絕也會回傳失敗，而不會把 exit code 0 誤認為有效結果。

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

## 授權與貢獻

本專案採用 [MIT License](LICENSE)。提交變更前請閱讀 [CONTRIBUTING.md](CONTRIBUTING.md)，安全性問題請參閱 [SECURITY.md](SECURITY.md)。
