# 6-sol-gemini3.8flash 架構

本版本以減少主代理上下文、透過較低成本的委派取得接近單一主代理的品質為設計目標。日常判斷採簡短規則，Gemini 為預設工作代理，主代理負責需求、架構、整合與驗收。

## 指令如何載入

| 元件 | 決策與理由 |
| --- | --- |
| `AGENTS.md` | 可選的一句委派時機。提供常駐觸發條件；使用者直接要求委派時也能啟動。安裝器以 managed block 合併，保留個人規則。 |
| `SKILL.md` | 集中短路由、交接、驗收與 Gemini 呼叫入口，按需載入。它是本專案的政策包裝，原生 spawn 工具本身可直接呼叫。 |
| `references/models.md` | 模型選擇有疑義時讀取，說明任務適用範圍、effort 取捨與證據解讀。 |
| `references/benchmarks.md` | 核對數據或調整政策時讀取，保存 10 項共同評測（13 profiles）、27 項基準評測（4 profiles）、各模型 effort 資料及來源。 |
| `references/antigravity.md` | 安裝、參數與故障排除。正常呼叫的必要資訊已在技能入口。 |
| PowerShell runner | 負責程序、逾時、工作目錄、模型參數驗證、JSON 驗證、輸出限長與本機紀錄。呼叫者明確選擇 Gemini medium／high，runner 傳遞該選擇。 |
| 原生代理設定 | 直接在 spawn 指定 Luna high／max 或 Sol medium／high／xhigh。具名角色、特定工具權限或獨立指令需要持久化時，可使用自訂 TOML。 |

OpenAI 的 [GPT-6 Astra 技能指引](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra) 建議縮短描述、按需讀取參考資料，並重新檢查過度細化的舊流程。[原生子代理文件](https://learn.chatgpt.com/docs/agent-configuration/subagents) 支援明確的 spawn 模型與 effort；自訂 TOML 是配置層，適用於需要持久化角色設定的情況。

本版本讓工作代理取得完成任務所需的上下文、檔案與驗收條件，回傳精簡結果及證據位置。主代理依風險檢查產物。正常情況讀取結果，診斷時再讀完整紀錄。

Gemini 委派由主代理提供簡短狀態：派出前一句話說明模型、effort 與任務，返回後在下一則必要更新交代結果或阻礙，區分工作完成與驗收。同批任務合併提示，規則放在技能的 Gemini 呼叫入口。

## Gemini 接入方式

Codex 的 [custom model provider](https://learn.chatgpt.com/docs/config-file/config-advanced#custom-model-providers) 確實允許連接第三方模型：provider 定義端點、認證與協定，Codex 提供代理執行環境。這能支持第三方模型在 Codex 工作，但 Gemini 模型接入與 Antigravity 完整代理的工具、登入及對話生命週期是兩個層次。

目前 [config reference](https://learn.chatgpt.com/docs/config-file/config-reference) 將 `model_providers.<id>.wire_api` 列為僅支援 `responses`。部分說明文字仍提及 Chat Completions，存在文件差異；部署自訂 provider 時應以目標 Codex 版本及端點協定確認相容性。原生子代理文件也未明確保證目前版本可在同一代理樹混用所有 provider。

本專案選用 [Antigravity CLI headless mode](https://antigravity.google/docs/cli/headless/)：它使用快取的登入憑證，提供 JSON 回傳、模型指定和逾時控制，符合沿用訂閱帳號的需求。Windows 的 PowerShell 7 是薄薄的程序介面，無需另開常駐服務。

| 介面 | 適用條件與本次判斷 |
| --- | --- |
| 官方 CLI | 已有訂閱登入、Windows 原生執行檔和單次任務介面，採用。 |
| 自訂 Codex provider／相容 gateway | 適合要讓第三方模型使用 Codex 工具的需求；需額外解決 Responses 相容、認證與各版本子代理路由。 |
| Antigravity SDK／託管 API | [SDK 文件](https://antigravity.google/docs/sdk/overview/) 示範 API key 或 Cloud 認證；尚無已核實的既有訂閱登入路徑。 |
| 自建 MCP 包裝 CLI | 可提供結構化工具介面，但增加服務生命週期、安裝與維護。本次 JSON runner 已處理交接需求。 |

## 日常路由

| 模型 | 日常預設 | 進一步選擇 |
| --- | --- | --- |
| Gemini | Medium：可完整交接的研究、整理、實作與審查 | High：深入推理、知識整合或較多不確定性 |
| Luna | High：需要原生工具或上下文，結果容易核對的證據蒐集與明確修改 | Max：範圍有限的判斷，細微錯誤會造成主代理大量返工 |
| Sol | Medium：需要原生工具或上下文、路徑清楚的多步工作 | High：複雜除錯、跨模組追蹤、假設及邊界條件分析；xHigh：需持續檢驗多個假設或釐清矛盾證據的困難子任務 |

Gemini 是可完整交接工作的優先選擇。需要 Codex 原生工具、無法有效移交的上下文，或已觀察到 Gemini 能力不足時，依任務範圍選擇 Luna 或 Sol。Luna Max 與 Sol Medium 的分工依範圍和協調需求判斷。較高 effort 可在首次委派時直接選用；結果不完整時，先分辨上下文、環境與能力問題，再決定修正或更換配置。

Luna 的選擇著重驗收與返工代價，以及等待是否會阻塞主代理。Max 優先承接可並行的工作；若答案會卡住下一步，可考慮交由 High 蒐集容易核對的證據，讓主代理完成相依的判斷。相關例子放在按需讀取的模型選擇說明。

主代理採用使用者選定的模型與 effort，可委派配置為表中七種。使用者選擇 Astra Low 作為主代理時，Sol xHigh 可承接需要更深入推理的子任務，形成工作分配上的互補。主代理依子任務條件選擇配置，無需讀取自身 model ID 或計算能力差距。Astra 各 effort 與 Sol Max 的評測保留供參考。

10 項共同評測可直接比較 13 個 profiles；27 項共同評測只比較 Astra Max、Sol Max、Gemini High、Luna Max。各模型獨立 effort 資料僅能比較同模型的不同 effort，保留率不能用來推算共同評測中的缺失分數。Weighted Cost Index 採對數正規化，越低越好；指數點差不代表實際費用或 Codex 額度的節省比例。
