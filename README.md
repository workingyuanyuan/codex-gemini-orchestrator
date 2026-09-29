# codex-gemini-orchestrator

Windows 11 上的 Codex 委派技能。主代理負責架構、整合與驗收，預設將可完整交接的工作委派給已登入 Antigravity 的 Gemini 3.8 Flash Medium，並在需要原生 Codex 能力時使用 Luna High 或 Sol Medium。依任務需要可選用 Gemini High、Luna Max、Sol High 或 Sol xHigh。

目前版本：`6-sol-gemini3.8flash`。

## 安裝

需要 Windows 11、PowerShell 7、Git、可使用原生子代理的 Codex，以及已登入訂閱帳號的官方 Antigravity CLI（`agy.exe`）。本版依據 Codex CLI `0.158.0-alpha.2.1`、Antigravity CLI `1.2.11` 的介面設計。

從 GitHub ZIP 執行時，若 PowerShell 因 `RemoteSigned` 政策封鎖下載標記，確認來源可信後解除安裝檔標記：

```powershell
Unblock-File -LiteralPath ./install.ps1
```

在專案根目錄執行：

```powershell
./install.ps1 -InstallDelegationTrigger
```

安裝位置為 `$env:CODEX_HOME`，未設定時使用 `$HOME\.codex`。`-InstallDelegationTrigger` 將一句委派時機合併到 `AGENTS.md` 的專用區塊，保留區塊外的文字。若已有自己的委派時機，執行 `./install.ps1` 即可安裝技能與 runner。

同名套件檔案已存在時，加上 `-Force` 更新：

```powershell
./install.ps1 -InstallDelegationTrigger -Force
```

`-Force` 會替換同名套件檔案及專用指令區塊；請先備份套件檔案中的個人修改。安裝後開啟新的 Codex 對話。

其他參數：`-Version <版本目錄名稱>`、`-DestinationRoot <安裝目錄>`。歷史版本仍可指定安裝；其中的原生 agent profiles 會隨該版本複製。升級時若本機有較早版本的委派規則或 `gpt-5-6-*.toml`，請檢查並移除已淘汰的規則，以免與新路由衝突。

## 使用

可以直接要求：

```text
使用 $model-routing-and-delegation-agy，將這項工作中可獨立驗收的部分委派出去。
```

| 工作 | 日常預設 | 選用較高 effort 的條件 |
| --- | --- | --- |
| 可完整交接、Antigravity 工具足以完成的研究、分析、實作、審查 | Gemini 3.8 Flash Medium | High：深入推理、知識整合或較多不確定性 |
| 需要原生 Codex 工具或上下文，結果容易核對的證據蒐集與明確修改 | GPT-6 Luna High | Max：範圍有限的判斷，細微錯誤會造成主代理大量返工；優先承接可並行的工作 |
| 需要原生 Codex 工具或上下文、路徑清楚的多步工作 | GPT-6 Sol Medium | High：複雜除錯、跨模組追蹤、假設與邊界條件分析；xHigh：需持續檢驗多個假設或釐清矛盾證據的困難子任務 |

主代理沿用使用者選定的模型與 effort，負責架構、整合與最終驗收。委派時依任務直接選用合適的配置；Luna Max 與 Sol Medium 依工作範圍及協調需求區分。

原生子代理在 spawn 時明確指定模型與 effort。選擇有疑義時查閱 [models.md](versions/6-sol-gemini3.8flash/skills/model-routing-and-delegation-agy/references/models.md)；完整數據、來源與比較範圍在 [benchmarks.md](versions/6-sol-gemini3.8flash/skills/model-routing-and-delegation-agy/references/benchmarks.md)。跨模型比較使用共同的 10 項（13 profiles）或 27 項（4 profiles）評測資料，各模型獨立的 effort 保留率僅用於同模型內比較。Weighted Cost Index 越低越好，指數點差不代表實際費用或額度的節省比例。

委派 Gemini 前，主代理以一句話交代模型、effort 與任務；結果返回後，在下一則必要更新交代結果或阻礙，並區分工作完成與主代理驗收。同批任務合併提示。

Gemini 的呼叫方式：

```powershell
$codexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$runner = Join-Path $codexRoot 'scripts/Invoke-AntigravityAgent.ps1'
& $runner -WorkingDirectory $worktree -PromptFile $contract -Model gemini-3.8-flash-medium -AutoApprove
```

`$worktree` 是乾淨、專用的 linked Git worktree 根目錄；`$contract` 是位於該 worktree 外的 UTF-8 任務檔。High 使用 `-Model gemini-3.8-flash-high`。runner 回傳精簡 JSON，完整結果與診斷存放於各次執行的本機目錄。主代理檢查退出碼、狀態及產物，再整合結果。工作目錄隔離不等於檔案系統沙箱，`-AutoApprove` 會允許 Antigravity 自動執行工具。

參數、回傳欄位與排錯請見 [Antigravity operations](versions/6-sol-gemini3.8flash/skills/model-routing-and-delegation-agy/references/antigravity.md)。

## 設計與檔案

[架構說明](docs/architecture.md) 記錄技能、AGENTS.md、原生 TOML、CLI、SDK、自訂 provider 與 MCP 的選擇依據，並連結官方文件。

```text
versions/6-sol-gemini3.8flash/
├─ AGENTS.md
├─ scripts/Invoke-AntigravityAgent.ps1
└─ skills/model-routing-and-delegation-agy/
   ├─ SKILL.md
   ├─ agents/openai.yaml
   └─ references/
      ├─ models.md
      ├─ benchmarks.md
      └─ antigravity.md
```

歷史配置保留在 `versions/6-gemini3.8flash/` 與 `versions/5.6*/`。版本目錄區分模型組合及路由配置。

## 驗證

在 PowerShell 7 執行離線回歸測試：

```powershell
pwsh -NoProfile -File ./tests/Invoke-AntigravityAgent.Tests.ps1
pwsh -NoProfile -File ./tests/Install.Tests.ps1
```

runner 測試使用本機假執行檔與臨時 Git 專案，安裝測試使用臨時目的地。

本專案採用 [MIT License](LICENSE)。貢獻流程見 [CONTRIBUTING.md](CONTRIBUTING.md)，安全問題見 [SECURITY.md](SECURITY.md)。
