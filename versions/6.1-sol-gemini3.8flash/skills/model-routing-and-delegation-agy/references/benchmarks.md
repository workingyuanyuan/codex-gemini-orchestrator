# Benchmark evidence

Snapshot recorded 2026-10-04 from the user-supplied shared benchmark tables. Use this reference for matched-coverage scores and routing tradeoffs.

## Comparison boundaries

| Dataset | Profiles | Valid comparison |
| --- | --- | --- |
| Shared 30 benchmarks | Astra max, GPT-6.1 Sol max, Gemini high, Luna max | Supplied Overall and dimension aggregates across these four profiles |
| Shared 11 benchmarks | 12 model/effort profiles | Supplied Overall and dimension aggregates across these profiles |

Compare scores within the same dataset and use the supplied Overall values. The evidence covers the aggregate scores for the profiles listed in each table.

Capability scores are higher-is-better. Effort labels use lowercase (`xhigh`).

## Shared 30-benchmark reference

| Model | Reasoning Effort | Overall | Agentic | Coding | Reasoning | Knowledge | Comprehension | Language |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | max | 65.5 | 45.1 | 68.8 | 80.7 | 60.3 | 55.6 | 82.5 |
| GPT-6.1 Sol | max | 64.4 | 44.6 | 66.3 | 78.6 | 59.4 | 55.6 | 82.1 |
| Gemini 3.8 Flash | high | 60.5 | 43.0 | 54.9 | 74.1 | 55.1 | 51.3 | 84.6 |
| GPT-6 Luna | max | 52.9 | 37.2 | 59.9 | 61.8 | 42.1 | 51.2 | 64.9 |

Astra max leads Overall, Agentic, Coding, Reasoning, and Knowledge, and ties GPT-6.1 Sol max on Comprehension. Gemini high leads Language. Interpret these results at the listed effort levels.

## Shared 11-benchmark comparison

| Model | Reasoning Effort | Overall | Agentic | Coding | Reasoning | Knowledge | Comprehension | Cost |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6 Astra | max | 54.9 | 48.5 | 61.0 | 63.4 | 58.6 | 31.0 | 81.7 |
| GPT-6 Astra | xhigh | 54.3 | 47.4 | 60.1 | 62.4 | 58.2 | 32.2 | 77.3 |
| GPT-6.1 Sol | max | 53.9 | 48.5 | 57.9 | 62.9 | 57.5 | 31.0 | 59.5 |
| GPT-6 Astra | high | 53.0 | 45.7 | 59.9 | 60.5 | 57.1 | 31.0 | 75.4 |
| GPT-6.1 Sol | high | 52.5 | 43.9 | 59.7 | 60.8 | 56.1 | 32.0 | 51.2 |
| GPT-6 Astra | medium | 52.1 | 43.3 | 58.6 | 60.6 | 56.7 | 30.4 | 72.7 |
| GPT-6.1 Sol | medium | 50.4 | 40.8 | 58.8 | 57.2 | 55.1 | 30.0 | 46.9 |
| GPT-6 Astra | low | 48.6 | 37.9 | 55.5 | 55.9 | 54.4 | 30.4 | 67.5 |
| Gemini 3.8 Flash | high | 46.9 | 39.5 | 56.1 | 53.7 | 51.2 | 21.0 | 32.1 |
| Gemini 3.8 Flash | medium | 44.7 | 39.0 | 55.8 | 47.6 | 47.6 | 22.8 | 21.5 |
| GPT-6 Luna | max | 40.6 | 36.3 | 54.5 | 39.4 | 41.1 | 22.8 | 32.1 |
| GPT-6 Luna | high | 33.1 | 29.5 | 49.0 | 23.4 | 37.9 | 18.2 | 21.5 |

### Selected measured differences

All deltas below are profile A minus profile B on the shared 11-benchmark set, in score or cost-index points.

| Profile A | Profile B | Overall | Agentic | Coding | Reasoning | Knowledge | Comprehension | Cost |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| GPT-6.1 Sol high | GPT-6.1 Sol medium | +2.1 | +3.1 | +0.9 | +3.6 | +1.0 | +2.0 | +4.3 |
| GPT-6.1 Sol max | GPT-6.1 Sol high | +1.4 | +4.6 | -1.8 | +2.1 | +1.4 | -1.0 | +8.3 |
| Gemini high | Gemini medium | +2.2 | +0.5 | +0.3 | +6.1 | +3.6 | -1.8 | +10.6 |
| Luna max | Luna high | +7.5 | +6.8 | +5.5 | +16.0 | +3.2 | +4.6 | +10.6 |
| GPT-6.1 Sol medium | Gemini high | +3.5 | +1.3 | +2.7 | +3.5 | +3.9 | +9.0 | +14.8 |

Sol high improves on medium in every supplied capability aggregate. Gemini high's largest gains over medium are Reasoning and Knowledge, with a small Coding gain and lower Comprehension. Luna max improves on high in every capability aggregate. Use these aggregate observations alongside task-specific evidence.

## Cost interpretation

Cost is the supplied relative cost index, with lower values preferred. Keep cost comparisons in index points. Consider tool fit, handoff overhead, latency, and review effort alongside these scores.

## Provenance

- Inputs: the user's shared 30-benchmark reference and shared 11-benchmark comparison supplied on 2026-10-04.
- Source project: `Frontier-Model-Doh-Choo-choo`.

Preserve the dataset, profile, coverage, and cost configuration when incorporating subsequent exports.
