# Benchmark evidence

Snapshot recorded 2026-09-29 from the user-supplied exports of `Frontier-Model-Doh-Choo-choo`. Use this reference for measured scores, coverage, and cost interpretation.

- [Comparison boundaries](#comparison-boundaries)
- [Shared 27-benchmark reference](#shared-27-benchmark-reference)
- [Shared 10-benchmark comparison](#shared-10-benchmark-comparison)
- [Weighted Cost Index](#weighted-cost-index)
- [Within-model effort evidence](#within-model-effort-evidence)
- [Provenance](#provenance)

## Comparison boundaries

| Dataset | Profiles | Valid comparison |
| --- | --- | --- |
| Shared 27 benchmarks | Astra max, Sol max, Luna max, Gemini high | Across these four profiles, using supplied aggregates or individual benchmarks |
| Shared 10 benchmarks | 13 model/effort profiles | Across all 13 profiles on each listed benchmark |
| Within-model effort datasets | Efforts of each individual model | Across efforts within that model's dataset |
| Weighted Cost Index | All 13 profiles | Relative cost index under the same source selection and normalization |

The shared ten benchmarks are a subset of the 27. All 40 overlapping measurements for the four baseline profiles agree. The remaining 17 benchmarks cover only those four profiles here. Overlap is not independent evidence.

Dimension names alone do not establish comparable coverage. Within-model dimension scores must not be compared across models or mixed with the shared 27-benchmark aggregates. Retention ratios cannot reconstruct unmeasured shared-set scores. No Overall or dimension aggregates are supplied for the ten-benchmark set.

Capability scores are higher-is-better. Effort labels are normalized to lowercase (`xhigh`). Differences describe the supplied measurements; uncertainty estimates and repeated-run results are unavailable.

## Shared 27-benchmark reference

All four profiles use the same 27 benchmarks. Overall and dimension scores below are the supplied aggregates; preserve their scoring basis rather than averaging the displayed benchmark rows to reconstruct them.

| Model | Effort | Overall | Agentic | Coding | Reasoning | Knowledge | Language |
| --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | max | 66.5 | 44.6 | 65.7 | 82.6 | 55.3 | 84.3 |
| GPT-6 Sol | max | 62.4 | 44.7 | 60.0 | 78.7 | 49.8 | 78.6 |
| Gemini 3.8 Flash | high | 59.4 | 43.0 | 49.9 | 69.6 | 50.2 | 84.6 |
| GPT-6 Luna | max | 54.2 | 41.2 | 50.0 | 66.2 | 42.3 | 71.2 |

Astra max leads Overall, Coding, Reasoning, and Knowledge. Sol max leads Agentic (44.7 versus Astra's 44.6); Gemini high leads Language. Sol max exceeds Gemini high in Overall, Agentic, Coding, and Reasoning; Gemini high exceeds Sol max in Knowledge and Language. Gemini high exceeds Luna max in Overall, Agentic, Reasoning, Knowledge, and Language; Luna max has a 0.1-point Coding lead.

### Per-benchmark results

| Benchmark | Astra max | Sol max | Luna max | Gemini high |
| --- | --- | --- | --- | --- |
| AA-Briefcase | 52.0 | 46.9 | 37.4 | 42.1 |
| AA-LCR | 80.7 | 83.7 | 83.3 | 81.3 |
| AA-Omniscience | 62.6 | 54.5 | 43.8 | 54.6 |
| ARC-AGI 2 | 95.0 | 89.6 | 59.3 | 89.2 |
| AutomationBench | 41.4 | 32.0 | 20.7 | 29.7 |
| Code Migration accuracy | 67.7 | 57.2 | 42.6 | 36.5 |
| CritPt | 31.7 | 30.9 | 19.4 | 18.3 |
| CyberBench v1.1 accuracy | 41.1 | 78.0 | 76.3 | 43.8 |
| EMB accuracy | 71.7 | 71.5 | 68.5 | 72.2 |
| Finance Agent (v2) accuracy | 53.5 | 49.0 | 49.9 | 61.4 |
| Frontier Code 1.1 | 53.3 | 49.3 | 42.4 | 38.0 |
| GDPval-AA | 52.1 | 49.3 | 43.4 | 45.6 |
| Harvey's Legal Agent Benchmark accuracy | 5.4 | 1.7 | 2.9 | 10.0 |
| Humanity’s Last Exam | 54.7 | 47.9 | 38.5 | 47.8 |
| IOI accuracy | 100.0 | 82.6 | 55.6 | 56.9 |
| Legal Research Bench accuracy | 39.4 | 28.8 | 30.3 | 38.9 |
| LiveBench Instruction Following | 75.6 | 68.6 | 55.9 | 81.4 |
| LiveBench Language | 89.4 | 85.3 | 73.8 | 87.8 |
| LiveBench Mathematics | 96.8 | 96.4 | 89.1 | 91.6 |
| LiveBench Reasoning | 92.7 | 88.7 | 81.8 | 89.3 |
| MedCode accuracy | 48.5 | 47.1 | 44.7 | 48.1 |
| MedScribe accuracy | 87.9 | 82.0 | 83.7 | 84.5 |
| ProgramBench accuracy | 5.5 | 2.0 | 0.5 | 1.0 |
| ProofBench v1.1 accuracy | 99.0 | 83.0 | 64.0 | 48.0 |
| SciCode | 56.5 | 57.6 | 54.6 | 56.6 |
| Terminal-Bench 2.1 | 87.3 | 83.1 | 73.0 | 81.3 |
| Vibe Code Bench v1.1 accuracy | 89.6 | 87.8 | 81.6 | 78.7 |

## Shared 10-benchmark comparison

Every profile below has measurements on the same ten benchmarks. The table is transposed into one row per profile for lookup. Benchmark names retain the source labels. Cost is listed separately to keep measurement coverage distinct from cost normalization.

| Model | Effort | AA-Briefcase | AA-LCR | AA-Omniscience | ARC-AGI 2 | AutomationBench | CritPt | Frontier Code 1.1 | GDPval-AA | Humanity’s Last Exam | SciCode |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | max | 52.0 | 80.7 | 62.6 | 95.0 | 41.4 | 31.7 | 53.3 | 52.1 | 54.7 | 56.5 |
| GPT-6 Sol | max | 46.9 | 83.7 | 54.5 | 89.6 | 32.0 | 30.9 | 49.3 | 49.3 | 47.9 | 57.6 |
| GPT-6 Luna | max | 37.4 | 83.3 | 43.8 | 59.3 | 20.7 | 19.4 | 42.4 | 43.4 | 38.5 | 54.6 |
| Gemini 3.8 Flash | high | 42.1 | 81.3 | 54.6 | 89.2 | 29.7 | 18.3 | 38.0 | 45.6 | 47.8 | 56.6 |
| GPT-6 Sol | medium | 30.8 | 82.3 | 53.4 | 57.8 | 26.9 | 24.6 | 45.9 | 41.0 | 41.0 | 53.8 |
| GPT-6 Sol | high | 39.4 | 83.7 | 53.7 | 68.9 | 31.2 | 25.4 | 47.7 | 43.8 | 44.1 | 54.9 |
| GPT-6 Luna | high | 32.0 | 79.3 | 42.8 | 31.4 | 14.5 | 15.4 | 37.3 | 39.5 | 32.9 | 50.3 |
| Gemini 3.8 Flash | medium | 41.1 | 84.0 | 53.0 | 82.9 | 29.7 | 12.3 | 41.2 | 45.4 | 42.1 | 55.1 |
| GPT-6 Astra | low | 40.2 | 80.0 | 59.5 | 85.4 | 30.3 | 26.3 | 45.3 | 43.3 | 49.2 | 54.1 |
| GPT-6 Astra | medium | 47.5 | 79.7 | 60.6 | 92.1 | 34.1 | 29.1 | 48.8 | 48.4 | 52.7 | 54.2 |
| GPT-6 Astra | high | 50.8 | 80.0 | 61.1 | 92.1 | 37.1 | 28.9 | 50.9 | 49.2 | 53.1 | 55.4 |
| GPT-6 Astra | xhigh | 52.3 | 80.0 | 61.9 | 93.3 | 39.0 | 31.4 | 50.6 | 50.8 | 54.6 | 55.7 |
| GPT-6 Sol | xhigh | 41.3 | 81.3 | 53.8 | 78.1 | 33.2 | 28.0 | 48.4 | 46.8 | 46.3 | 55.1 |

### Selected measured differences

Counts report A's higher / equal / lower scores across the ten benchmarks. They do not weight effect size or task relevance and are not an Overall ranking. Cost deltas are index points, A minus B.

| Profile A | Profile B | Higher / equal / lower | Cost index delta |
| --- | --- | --- | --- |
| Gemini 3.8 Flash medium | Gemini 3.8 Flash high | 2 / 1 / 7 | -7.2 |
| Gemini 3.8 Flash high | GPT-6 Sol high | 6 / 0 / 4 | -23.3 |
| Gemini 3.8 Flash medium | GPT-6 Luna high | 9 / 0 / 1 | +0.0 |
| GPT-6 Sol high | GPT-6 Sol medium | 10 / 0 / 0 | +2.0 |
| GPT-6 Sol xhigh | GPT-6 Sol high | 9 / 0 / 1 | +3.7 |
| GPT-6 Sol max | GPT-6 Sol xhigh | 9 / 0 / 1 | +9.5 |
| GPT-6 Astra low | GPT-6 Sol high | 5 / 0 / 5 | +16.2 |

- Gemini medium exceeds high on AA-LCR (+2.7) and Frontier Code 1.1 (+3.2), ties AutomationBench, and trails on the other seven. Its SciCode score is 1.5 lower; the Frontier Code result alone does not establish a general coding advantage.
- Gemini high exceeds Sol high on six benchmarks, including ARC-AGI 2 (+20.3). Sol high leads on AA-LCR, AutomationBench, CritPt, and Frontier Code 1.1.
- Sol high exceeds medium on all ten; the largest increases are ARC-AGI 2 (+11.1) and AA-Briefcase (+8.6).
- Sol xhigh exceeds high on nine and trails on AA-LCR (-2.4). Sol max exceeds xhigh on nine but trails on AutomationBench (-1.2). Higher effort does not guarantee a higher score on every benchmark.

## Weighted Cost Index

Lower is better. These are the user's supplied common index values, recorded separately from capability scores.

| Model | Effort | Weighted Cost Index |
| --- | --- | --- |
| GPT-6 Astra | max | 81.0 |
| GPT-6 Sol | max | 66.0 |
| GPT-6 Luna | max | 29.5 |
| Gemini 3.8 Flash | high | 29.5 |
| GPT-6 Sol | medium | 50.8 |
| GPT-6 Sol | high | 52.8 |
| GPT-6 Luna | high | 22.3 |
| Gemini 3.8 Flash | medium | 22.3 |
| GPT-6 Astra | low | 69.0 |
| GPT-6 Astra | medium | 72.8 |
| GPT-6 Astra | high | 75.5 |
| GPT-6 Astra | xhigh | 78.0 |
| GPT-6 Sol | xhigh | 56.5 |

The source project's `apps/bench/lib/view-model.ts` implements source-local logarithmic min-max normalization:

`index_s = 100 * (ln(cost_s) - min_s) / (max_s - min_s)`

Here `min_s` and `max_s` are extrema of log task costs in the applicable source population; a constant range maps to 50. `buildAdvancedCostSeries` gives selected sources equal weight and uses the full product population for each source's normalization range. Its weighted index is the mean of these normalized source values.

Index point differences are valid within a fixed configuration. Index ratios or percentage decreases do not measure dollar savings, Codex quota savings, or workflow expenditure. Reproduction of the supplied values requires the export's selected sources, source costs, population, and any user conversion; those exact export settings are not included in this snapshot. The code establishes the normalization method, not an independent reproduction of the supplied index values.

## Within-model effort evidence

Each subsection has its own matched benchmark coverage across efforts. Coverage differs between models and from the shared sets above. Overall is unavailable for these datasets. The four dimensions are preserved separately; summing them would introduce an additional aggregate with no supplied weighting rationale.

The Astra, Gemini, and Luna dimension scores below were supplied on 2026-09-27. Sol's dimension scores were supplied on 2026-09-29. Exact benchmark membership and export weights for these within-model datasets are not captured here. Cost for each profile is defined in the common index table above.

### GPT-6 Astra

| Effort | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- |
| max | 46.7 | 67.6 | 75.9 | 58.6 |
| xhigh | 46.3 | 67.4 | 75.3 | 58.2 |
| high | 44.3 | 67.4 | 74.0 | 57.1 |
| medium | 41.4 | 66.3 | 73.7 | 56.7 |
| low | 36.4 | 63.6 | 71.2 | 54.4 |

### GPT-6 Sol

| Effort | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- |
| max | 42.7 | 53.5 | 68.0 | 51.2 |
| xhigh | 40.4 | 51.8 | 62.5 | 50.1 |
| high | 38.1 | 51.3 | 59.3 | 48.9 |
| medium | 32.9 | 49.9 | 54.9 | 47.2 |

### Gemini 3.8 Flash

| Effort | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- |
| high | 40.6 | 62.4 | 71.0 | 51.2 |
| medium | 40.5 | 62.8 | 68.2 | 47.6 |

### GPT-6 Luna

| Effort | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- |
| max | 33.8 | 48.5 | 54.0 | 41.1 |
| high | 28.7 | 43.8 | 42.1 | 37.9 |

For a within-model dimension, retention can be calculated as `effort score / baseline score`, with max as baseline for GPT-6 models and high for Gemini. Such ratios describe that dimension's measured scores only; they are not task success probabilities or a guaranteed proportion of general capability.

## Provenance

- Source project: [Frontier-Model-Doh-Choo-choo](https://github.com/workingyuanyuan/Frontier-Model-Doh-Choo-choo).
- Inputs: user-supplied shared 27-benchmark aggregates and raw results, shared ten-benchmark results for 13 profiles, Weighted Cost Index values, and within-model dimension exports.
- Source implementation inspected: `apps/bench/lib/view-model.ts`, particularly `normalizeCost` and `buildAdvancedCostSeries`; repository HEAD `476661c`, inspected 2026-09-29.
- The source project collects benchmark and cost evidence from multiple providers. Export capture dates here do not establish the underlying benchmark run dates.

Preserve the dataset, profile, benchmark coverage, and cost configuration when incorporating subsequent exports. Cross-profile claims should identify the matched dataset that supports them.
