# Gemini task contracts

Read the relevant section when selecting a Gemini capability or preparing its handoff. Use the model selection and acceptance rules in [SKILL.md](../SKILL.md), and the workspace requirements and invocation procedures in [Antigravity operations](antigravity.md). The contract grants native Antigravity tools and the specific workflow needed for the assignment.

## Writing and localization

Use Gemini for README narrative, onboarding explanations, tutorials, product copy and localization. Supply the audience, language, tone, length, terminology and source files that establish the facts. Ask for the finished text or a patch to named files. Check commands, flags and product claims against the repository before acceptance.

Example contract:

```text
Rewrite README.md's introduction and quick-start explanation for developers trying this project for the first time. Use concise Traditional Chinese and the terminology in docs/glossary.md. Establish the installation steps from install.ps1. Edit the assigned README sections and return the patch with references supporting technical claims. Complete the assignment directly using native Antigravity tools.
```

The shared 30-benchmark table gives Gemini high the highest Language score among the supplied profiles: 84.6. Use this as supporting evidence for language-heavy assignments. Select medium/high by the task's synthesis and reasoning needs. See [benchmark evidence](benchmarks.md#shared-30-benchmark-reference).

## Multimodal understanding

Gemini 3.8 Flash accepts images, PDFs, audio and video as model inputs. Use Antigravity's native file access to supply them: give absolute readable file paths or include the files in the worker's clean snapshot. Ask the worker to open the media with `view_file`, then return observations grounded in the relevant page, region or time interval. [Model input types](https://ai.google.dev/gemini-api/docs/models/gemini-3.8-flash)

| Input | Example assignment | Evidence to request |
| --- | --- | --- |
| Image | Read a diagram, extract visible text, compare a screenshot with a specified UI requirement | File path and region or element |
| PDF | Explain a chart or reconcile a table with surrounding text | Page number, table or figure label |
| Audio | Transcribe a passage, identify sounds, summarize a recording | Timestamps and uncertain passages |
| Video | Identify event order, summarize a demonstration, diagnose a recorded UI failure | Timestamp ranges and observed actions |

Use medium for clear extraction and description; high for ambiguous evidence or synthesis across media and code. Verify media access and consequential observations against the task's actual inputs.

Example contract:

```text
Inspect the video at <absolute-path> with native file access. Find where the displayed total diverges from the cart contents. Return the timestamp, visible evidence and relevant source-code locations in src/cart. Treat repository files as read-only and complete the analysis directly.
```

## Public web research

Use native `search_web` and available page-reading tools for focused research and source synthesis. State the question, recency requirements and authoritative source types. Request direct links and a concise connection between each finding and its supporting source. Use medium for a focused lookup and high for reconciling conflicting evidence.

## Browser interaction

Antigravity's built-in `/browser` workflow performs interactive web research and UI inspection. Select it for rendered-page evidence, reproduction steps and screenshot-based verification. The current session must provide a working native browser connection. [Built-in browser](https://antigravity.google/docs/subagents/)

Start the contract with `/browser`. Use medium for specified steps and high for diagnosis. Specify target URLs, allowed interactions, relevant viewport sizes, artifact location and observable success criteria. Permit the built-in browser subagent for this assignment and use [supervised execution](antigravity.md#supervise-browser-and-boost). First request a page open and a verifiable title or screenshot; proceed after that succeeds. For a headless-browser requirement, verify that the browser session itself runs headlessly.

Example contract:

```text
/browser Inspect the running app at http://localhost:3000. Open the page and confirm its title, then test the navigation menu at 390x844 and 1280x800. Permitted interactions: opening navigation, following local links and resizing the viewport. Use the native browser workflow. Save screenshots to <absolute-artifact-directory> and return the URLs, reproduction steps and evidence of any clipped controls. Time budget: 180 seconds. Finish by disposing of this assignment's browser subagent and confirming its final state.
```

Accept browser work from successful operations and artifacts. A connection failure is a capability gap to resolve before repeating the assignment. Antigravity's browser documentation describes screenshots and action recordings for its IDE surface; check the artifacts available on the executing surface. [Browser operations](https://antigravity.google/docs/ide/browser/)

## Boost

`/boost` coordinates investigation or implementation with independent verification. Use it for a bounded problem where testing competing hypotheses or solutions adds value: a concurrency defect, difficult algorithm, or coupled refactor with clear acceptance criteria. It is available on supported paid Antigravity plans. [Boost workflow](https://antigravity.google/docs/boost/)

Start the contract with `/boost` and usually select `gemini-3.8-flash-high`. Provide the reproduction, scope of edits, tests, deliverable and total time budget. Authorize Boost's built-in investigation, implementation and verification descendants. Follow [supervised execution](antigravity.md#supervise-browser-and-boost) to track the resulting tree and dispose of it after collecting the evidence.

Example contract:

```text
/boost Reproduce the intermittent cache eviction race described in <issue-file>. Investigate competing causes and implement a fix within src/cache and tests/cache. Use native Antigravity tools and Boost's built-in worker hierarchy for investigation and independent verification. Total time budget: 600 seconds. Return the reproduction, patch, test results and relevant worker evidence. End with the final child inventory after disposing of this assignment's worker tree.
```

Record the root model and available child configuration separately. Use explicit inheritance where the workflow exposes a model control, and inspect the resolved model/effort when reported. Record unavailable child settings or usage as unknown in the execution evidence. Accept the result after reviewing the patch, verification artifacts and final child inventory.
