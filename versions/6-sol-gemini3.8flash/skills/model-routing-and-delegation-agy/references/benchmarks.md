# Benchmark evidence

Read for exact scores, comparison coverage, or source review. Use [model selection](models.md) for task-fit interpretation.

- [Comparison boundaries](#comparison-boundaries)
- [Shared 9-benchmark comparison](#shared-9-benchmark-comparison)
- [Shared 25-benchmark reference](#shared-25-benchmark-reference)
- [Within-model effort evidence](#within-model-effort-evidence)
- [Provenance](#provenance)

## Comparison boundaries

There are three kinds of capability evidence and one common Cost scale:

| Evidence | Valid comparison | Scope |
| --- | --- | --- |
| Shared 9-benchmark results | Across all 12 model/effort profiles, benchmark by benchmark | Same nine benchmarks for every profile |
| Shared 25-benchmark reference table and per-benchmark results | Across models at the listed efforts | Astra max, Sol max, Gemini high, Luna max |
| Each model's effort dataset | Across efforts of that same model | Benchmark coverage is held constant within the model, but differs between models |
| Cost | Across all listed models and efforts | User-defined common scale; lower is better |

Use the shared nine-benchmark results for direct comparisons among all 12 profiles. Use the shared 25-benchmark table for broader coverage of its four baseline profiles. Use each model's separate effort dataset to understand its own effort tradeoffs. Matching dimension names do not make the separate effort datasets comparable across models: the same model/effort can have different aggregates under different benchmark coverage.

Do not compare capability scores or subtest totals between the separate effort datasets. Do not multiply a shared-table score by an effort retention ratio to manufacture a comparable lower-effort score. Direct measurements for all 12 profiles are available on the nine-benchmark set; comparisons on the additional 16 benchmarks remain limited to the four profiles in the 25-benchmark table.

The effort datasets' exact benchmark membership and aggregation details were not supplied. Their retention percentages describe measured scores on their respective sets, not task success probabilities or a guaranteed share of general capability.

## Shared 9-benchmark comparison

User-supplied matched results for all 12 model/effort profiles, recorded 2026-09-27. Every profile uses the same nine benchmark columns. These scores support direct cross-model and cross-effort comparisons on each listed benchmark.

The nine benchmarks are a subset of the shared 25-benchmark set. For Astra max, Sol max, Gemini high, and Luna max, all 36 overlapping scores agree with the 25-benchmark table. This expands profile coverage while narrowing benchmark coverage; the overlapping results are not independent additional evidence.

Cost is carried over from the user's common Cost scale. No Overall or dimension aggregates were supplied for this nine-benchmark set. Benchmark counts and individual score differences describe this set; they do not provide an overall capability ranking or reconstruct the 25-benchmark Overall.

| Model | Effort | Cost | AA-Briefcase | AA-LCR | AA-Omniscience | AutomationBench | CritPt | Frontier Code 1.1 | GDPval-AA | Humanity’s Last Exam | SciCode |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Gemini 3.8 Flash | medium | 18.1 | 41.1 | 84.0 | 53.0 | 29.7 | 12.3 | 41.2 | 45.4 | 42.1 | 55.1 |
| Gemini 3.8 Flash | high | 28.2 | 42.1 | 81.3 | 54.6 | 29.7 | 18.3 | 38.0 | 45.6 | 47.8 | 56.6 |
| GPT-6 Luna | high | 18.1 | 32.0 | 79.3 | 42.8 | 14.5 | 15.4 | 37.3 | 39.5 | 32.9 | 50.3 |
| GPT-6 Luna | max | 28.2 | 37.4 | 83.3 | 43.8 | 20.7 | 19.4 | 42.4 | 43.4 | 38.5 | 54.6 |
| GPT-6 Sol | medium | 53.4 | 30.8 | 82.3 | 53.4 | 26.9 | 24.6 | 45.9 | 41.0 | 41.0 | 53.8 |
| GPT-6 Sol | high | 57.6 | 39.4 | 83.7 | 53.7 | 31.2 | 25.4 | 47.7 | 43.8 | 44.1 | 54.9 |
| GPT-6 Sol | max | 67.6 | 46.9 | 83.7 | 54.5 | 32.0 | 30.9 | 49.3 | 49.3 | 47.9 | 57.6 |
| GPT-6 Astra | low | 72.7 | 40.2 | 80.0 | 59.5 | 30.3 | 26.3 | 45.3 | 43.3 | 49.2 | 54.1 |
| GPT-6 Astra | medium | 77.7 | 47.5 | 79.7 | 60.6 | 34.1 | 29.1 | 48.8 | 48.4 | 52.7 | 54.2 |
| GPT-6 Astra | high | 80 | 50.8 | 80.0 | 61.1 | 37.1 | 28.9 | 50.9 | 49.2 | 53.1 | 55.4 |
| GPT-6 Astra | xhigh | 82 | 52.3 | 80.0 | 61.9 | 39.0 | 31.4 | 50.6 | 50.8 | 54.6 | 55.7 |
| GPT-6 Astra | max | 86 | 52.0 | 80.7 | 62.6 | 41.4 | 31.7 | 53.3 | 52.1 | 54.7 | 56.5 |

### Selected profile comparisons

Counts below indicate how many of the nine benchmarks give A a higher, equal, or lower score than B. Counts do not weight the size or task relevance of each difference.

| Profile A | Profile B | Cost A / B | A higher / equal / lower |
| --- | --- | --- | --- |
| Gemini medium | Gemini high | 18.1 / 28.2 | 2 / 1 / 6 |
| Gemini high | Sol high | 28.2 / 57.6 | 5 / 0 / 4 |
| Gemini medium | Luna high | 18.1 / 18.1 | 8 / 0 / 1 |
| Sol high | Sol medium | 57.6 / 53.4 | 9 / 0 / 0 |
| Astra low | Sol high | 72.7 / 57.6 | 4 / 0 / 5 |

- **Gemini medium versus high:** medium is higher on AA-LCR (+2.7) and Frontier Code 1.1 (+3.2), equal on AutomationBench, and lower on the other six benchmarks. SciCode is lower by 1.5, CritPt by 6.0, and Humanity's Last Exam by 5.7. Cost is 35.8% lower.
- **Gemini high versus Sol high:** Gemini is higher on AA-Briefcase, AA-Omniscience, GDPval-AA, Humanity's Last Exam, and SciCode. Sol is higher on AA-LCR, AutomationBench, CritPt, and Frontier Code 1.1. Sol's leads are 7.1 on CritPt and 9.7 on Frontier Code 1.1; Gemini's Cost is lower. The two profiles offer different strengths on this matched set.
- **Gemini medium versus Luna high:** both have Cost 18.1. Gemini is higher on eight benchmarks; Luna is higher on CritPt (15.4 versus 12.3).
- **Sol high versus medium:** high is higher on all nine benchmarks for about 7.9% more Cost. The largest point increases are AA-Briefcase (+8.6) and AutomationBench (+4.3).
- **Astra low versus Sol high:** Astra is higher on AA-Briefcase, AA-Omniscience, CritPt, and Humanity's Last Exam; Sol is higher on the other five. Astra's largest leads are AA-Omniscience (+5.8) and Humanity's Last Exam (+5.1), with about 26.2% more Cost. Astra profiles are retained as reference measurements.

## Shared 25-benchmark reference

User-supplied snapshot, recorded 2026-09-27. All four rows use the same 25 benchmarks listed below. Capability scores are higher-is-better; Cost is lower-is-better. Preserve the supplied Overall and dimension aggregates; the benchmark-to-dimension mapping and aggregation weights were not supplied here.

| Model | Reasoning effort | Overall | Agentic | Coding | Reasoning | Knowledge | Language | Cost |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | max | 66.1 | 45.1 | 65.7 | 80.2 | 55.3 | 84.3 | 86 |
| GPT-6 Sol | max | 61.0 | 39.9 | 60.0 | 76.5 | 49.8 | 78.6 | 67.6 |
| Gemini 3.8 Flash | high | 58.6 | 42.9 | 49.9 | 65.7 | 50.2 | 84.6 | 28.2 |
| GPT-6 Luna | max | 53.4 | 36.1 | 50.0 | 67.5 | 42.3 | 71.2 | 28.2 |

At these specific efforts:

- Astra max leads Overall, Agentic, Coding, Reasoning, and Knowledge. Gemini high leads Language.
- Sol max exceeds Gemini high in Overall, Coding, and Reasoning. Gemini high exceeds Sol max in Agentic, Knowledge, and Language, with lower Cost.
- Gemini high and Luna max have equal Cost. Luna max is slightly ahead in Coding and ahead in Reasoning; Gemini high is ahead in Overall, Agentic, Knowledge, and Language.
- Aggregate rankings can conceal task-specific differences. For example, Gemini high scores above Sol max on Finance Agent (v2), while Sol max scores above Gemini high on Code Migration. Use relevant individual benchmarks when assessing task fit.

### Per-benchmark results

All columns below use the same benchmark row. The model order matches the reference table.

| # | Benchmark | Astra max | Sol max | Gemini high | Luna max |
| --- | --- | --- | --- | --- | --- |
| 1 | AA-Briefcase | 52.0 | 46.9 | 42.1 | 37.4 |
| 2 | AA-LCR | 80.7 | 83.7 | 81.3 | 83.3 |
| 3 | AA-Omniscience | 62.6 | 54.5 | 54.6 | 43.8 |
| 4 | AutomationBench | 41.4 | 32.0 | 29.7 | 20.7 |
| 5 | Code Migration accuracy | 67.7 | 57.2 | 36.5 | 42.6 |
| 6 | CritPt | 31.7 | 30.9 | 18.3 | 19.4 |
| 7 | EMB accuracy | 71.7 | 71.5 | 72.2 | 68.5 |
| 8 | Finance Agent (v2) accuracy | 53.5 | 49.0 | 61.4 | 49.9 |
| 9 | Frontier Code 1.1 | 53.3 | 49.3 | 38.0 | 42.4 |
| 10 | GDPval-AA | 52.1 | 49.3 | 45.6 | 43.4 |
| 11 | Harvey's Legal Agent Benchmark accuracy | 5.4 | 1.7 | 10.0 | 2.9 |
| 12 | Humanity’s Last Exam | 54.7 | 47.9 | 47.8 | 38.5 |
| 13 | IOI accuracy | 100.0 | 82.6 | 56.9 | 55.6 |
| 14 | Legal Research Bench accuracy | 39.4 | 28.8 | 38.9 | 30.3 |
| 15 | LiveBench Instruction Following | 75.6 | 68.6 | 81.4 | 55.9 |
| 16 | LiveBench Language | 89.4 | 85.3 | 87.8 | 73.8 |
| 17 | LiveBench Mathematics | 96.8 | 96.4 | 91.6 | 89.1 |
| 18 | LiveBench Reasoning | 92.7 | 88.7 | 89.3 | 81.8 |
| 19 | MedCode accuracy | 48.5 | 47.1 | 48.1 | 44.7 |
| 20 | MedScribe accuracy | 87.9 | 82.0 | 84.5 | 83.7 |
| 21 | ProgramBench accuracy | 5.5 | 2.0 | 1.0 | 0.5 |
| 22 | ProofBench v1.1 accuracy | 99.0 | 83.0 | 48.0 | 64.0 |
| 23 | SciCode | 56.5 | 57.6 | 56.6 | 54.6 |
| 24 | Terminal-Bench 2.1 | 87.3 | 83.1 | 81.3 | 73.0 |
| 25 | Vibe Code Bench v1.1 accuracy | 89.6 | 87.8 | 78.7 | 81.6 |

## Within-model effort evidence

Each subsection is a separate capability comparison set. Capability scores and totals are comparable only inside that subsection. Cost retains the common cross-model scale.

Subtest total is the sum of Agentic, Coding, Reasoning, and Knowledge in that model's effort dataset. It is distinct from Overall in the shared reference table and does not include Language.

Within each model:

- Cost reduction = `(baseline cost - cost) / baseline cost`.
- Score retention = `score / baseline score`, using the same dimension and benchmark coverage.
- Total loss = `100% - total retention`.

Percentages preserve the user's rounded values. Effort labels use lowercase, including `xhigh`.

### GPT-6 Astra

Baseline: **max**, within this model's effort dataset.

| Effort | Cost | Subtest total | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- | --- | --- |
| max | 86 | 248.8 | 46.7 | 67.6 | 75.9 | 58.6 |
| xhigh | 82 | 247.2 | 46.3 | 67.4 | 75.3 | 58.2 |
| high | 80 | 242.8 | 44.3 | 67.4 | 74.0 | 57.1 |
| medium | 77.7 | 238.1 | 41.4 | 66.3 | 73.7 | 56.7 |
| low | 72.7 | 225.6 | 36.4 | 63.6 | 71.2 | 54.4 |

| Effort | Cost reduction | Total retention | Total loss | Agentic retention | Coding retention | Reasoning retention | Knowledge retention |
| --- | --- | --- | --- | --- | --- | --- | --- |
| xhigh | 4.7% | 99.4% | 0.6% | 99.1% | 99.7% | 99.2% | 99.3% |
| high | 7.0% | 97.6% | 2.4% | 94.9% | 99.7% | 97.5% | 97.4% |
| medium | 9.7% | 95.7% | 4.3% | 88.7% | 98.1% | 97.1% | 96.8% |
| low | 15.5% | 90.7% | 9.3% | 77.9% | 94.1% | 93.8% | 92.8% |

Within Astra's effort dataset, Coding changes little from max to high, while Agentic declines more as effort falls. These measurements describe Astra's own tradeoffs. Use the shared nine-benchmark results above to compare Astra low directly with other models.

### GPT-6 Sol

Baseline: **max**, within this model's effort dataset.

| Effort | Cost | Subtest total | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- | --- | --- |
| max | 67.6 | 204.7 | 42.7 | 53.5 | 57.3 | 51.2 |
| high | 57.6 | 192.8 | 38.1 | 51.3 | 54.5 | 48.9 |
| medium | 53.4 | 183.5 | 32.9 | 49.9 | 53.5 | 47.2 |

| Effort | Cost reduction | Total retention | Total loss | Agentic retention | Coding retention | Reasoning retention | Knowledge retention |
| --- | --- | --- | --- | --- | --- | --- | --- |
| high | 14.8% | 94.2% | 5.8% | 89.2% | 95.9% | 95.1% | 95.5% |
| medium | 21.0% | 89.6% | 10.4% | 77.0% | 93.3% | 93.4% | 92.2% |

Within Sol's effort dataset, moving from medium to high raises Cost by about 7.9% and Agentic by about 15.8%. The shared nine-benchmark results separately establish direct comparisons with Gemini high and Astra low on that matched set.

### Gemini 3.8 Flash

Baseline: **high**, within this model's effort dataset.

| Effort | Cost | Subtest total | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- | --- | --- |
| high | 28.2 | 225.2 | 40.6 | 62.4 | 71.0 | 51.2 |
| medium | 18.1 | 219.1 | 40.5 | 62.8 | 68.2 | 47.6 |

| Effort | Cost reduction | Total retention | Total loss | Agentic retention | Coding retention | Reasoning retention | Knowledge retention |
| --- | --- | --- | --- | --- | --- | --- | --- |
| medium | 35.8% | 97.3% | 2.7% | 99.8% | 100.6% | 96.1% | 93.0% |

Within Gemini's effort dataset, medium versus high changes Agentic by -0.1 points, Coding by +0.4, Reasoning by -2.8 (3.9% loss), and Knowledge by -3.6 (7.0% loss). The supplied breakdown highlights ARC-AGI 2 (-6.3) and CritPt (-6.0) for Reasoning, and Humanity's Last Exam (-5.7) for Knowledge. ARC-AGI 2 is outside the shared 25-benchmark table.

The small Coding lead has no supplied uncertainty estimate or repeated-run results, so it does not establish a reliable advantage across coding tasks.

### GPT-6 Luna

Baseline: **max**, within this model's effort dataset.

| Effort | Cost | Subtest total | Agentic | Coding | Reasoning | Knowledge |
| --- | --- | --- | --- | --- | --- | --- |
| max | 28.2 | 177.4 | 33.8 | 48.5 | 54.0 | 41.1 |
| high | 18.1 | 152.5 | 28.7 | 43.8 | 42.1 | 37.9 |

| Effort | Cost reduction | Total retention | Total loss | Agentic retention | Coding retention | Reasoning retention | Knowledge retention |
| --- | --- | --- | --- | --- | --- | --- | --- |
| high | 35.8% | 86.0% | 14.0% | 84.9% | 90.3% | 78.0% | 92.2% |

Within Luna's effort dataset, high versus max changes Agentic by -5.1 points (15.1% loss), Coding by -4.7 (9.7% loss), Reasoning by -11.9 (22.0% loss), and Knowledge by -3.2 (7.8% loss). This supports distinguishing clear, narrowly scoped work from work requiring substantial inference when selecting Luna's effort.

## Provenance

The user's `Frontier-Model-Doh-Choo-choo` project aggregates Artificial Analysis, Frontier Code and Zapier material. The user supplied the shared nine-benchmark results for 12 profiles, the shared 25-benchmark table and raw results for four profiles, the separate within-model effort profiles, and the common Cost values. Underlying benchmark run dates were not supplied.

Cost incorporates the user's conversion and is comparable across all supplied settings. No currency, billing unit, or reproducible conversion formula was supplied. Treat it as a common cost scale rather than a direct measurement of API charges, Codex quota consumption, or total workflow expenditure.

Keep this snapshot stable until new evidence is intentionally incorporated. Extending comparisons beyond the supplied matched coverage requires additional matched measurements. Any estimates require an explicitly justified method and must be labeled separately from measurements.
