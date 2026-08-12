# codex-gemini-orchestrator

這個專案解決的主要痛點是：**讓精簡的 `AGENTS.md` 按需載入模型路由 skill，再把任務委派給合適的子代理；其中包含原生 Codex agent 與透過官方 Antigravity CLI 使用外部模型，並沿用既有訂閱登入狀態，不需要 API Key 計費方案。**

Codex 負責架構、拆解、整合、審查與最終驗收；子代理只執行範圍明確、可客觀驗證的單次任務。

## 版本

- `versions/5.6-gemini3.6flash/`：目前版本，包含按需載入的路由 skill、原生 GPT-5.6 Luna Max agent 與 Antigravity workers。
- `versions/5.6-gemini3.5flash/`：已廢棄，僅保留作為版本紀錄。
- `versions/5.6/`：早期 GPT-5.6 多模型路由基準。

目前版本包含：

```text
versions/5.6-gemini3.6flash/
├─ AGENTS.md
├─ agents/
│  └─ gpt-5-6-luna-max.toml
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
./install.ps1 -Version 5.6-gemini3.6flash
```

安裝器會把 `AGENTS.md`、`agents/`、`scripts/` 與 `skills/` 複製到 `$HOME\.codex`。若已有同名檔案，安裝會列出衝突並中止；確認備份後可使用 `-Force` 只覆寫列出的檔案：

```powershell
./install.ps1 -Version 5.6-gemini3.6flash -Force
```

## 模型路由

`model-routing-and-delegation-agy` skill 使用以下入口：

- `gpt_5_6_luna_max`：原生 GPT-5.6 Luna Max agent，用於需要探索、跨檔修改或反覆 build-test-fix 的複雜 bounded execution。
- `gemini-3.6-flash` → `gemini-3.6-flash-high`：預設 bounded worker。
- `gemini-3.5-flash` → `gemini-3.5-flash-high`：邊界明確、可驗證的 TypeScript 與 Python 工作；DeepSWE 型任務優先交給 Gemini 3.6 Flash 或 Luna Max。
- `gemini-3.1-pro` → `gemini-3.1-pro-high`：密集規格、嚴格指令、語言精度、困難數學與資料工作。
- `claude-opus-4-6` → `claude-opus-4-6-thinking`：精密除錯、微妙不變量、複雜因果與大型跨檔理解。

GPT-5.6 Sol Max 只作為主代理與能力比較基準，不是可委派的 worker。封裝腳本會用 `agy models` 驗證外部 alias，並透過已登入的 Antigravity 訂閱工作階段執行單次、無狀態任務。

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
