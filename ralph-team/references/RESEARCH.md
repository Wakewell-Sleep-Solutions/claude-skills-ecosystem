# Team Skill: Research Evidence

Full citations backing every principle. Agents read this when they need depth on WHY.

## Principle 1: Sample Multiple Paths, Select the Best

**Self-Consistency (Wang et al. 2022)** — "Self-Consistency Improves Chain of Thought Reasoning in Language Models." Sample N reasoning paths, majority vote. +17.9% on GSM8K. Different paths hit different failure modes; majority filters individual errors.

**CISC (2024)** — Same accuracy with 46% fewer samples via confidence weighting. Application: weight 7+ findings read first.

**A-HMAD (2025)** — Heterogeneous model ensembles with adaptive weighting > homogeneous debate. Use DIFFERENT model families.

**ICE Framework (2025)** — +27% through iterative cross-model consensus. Application: Round 2 challenge-and-merge.

## Principle 2: Quality Early Compounds Into Velocity

**Google Developer Productivity (2024)** — Lagged panel analysis: code quality CAUSES future velocity. Causal direction proven.

**DORA (10-year, 39K professionals)** — Speed and stability positively correlated. Elite teams are faster AND more stable. Small batches drive both.

**Capers Jones (12K projects)** — Code review: 60-65% defect detection vs 25-45% testing. Cross-model review > self-review.

## Principle 3: Decompose Into Fundamentals

**Miller (1956)** — Working memory: 7±2 items. Max 7 crystallized findings = cognitive limit.

**Tree-of-Thought (Yao et al. 2023)** — Decomposition + branch evaluation > linear CoT on strategic tasks.

**Chunking (Chase & Simon 1973)** — Experts compress into meaningful chunks. Crystallization IS chunking.

## Principle 4: External Verification > Self-Assessment

**Huang et al. (2024)** — "Large Language Models Cannot Self-Correct." Self-correction WITHOUT external feedback HURTS accuracy. Models second-guess correct answers.

**Wharton AI Lab (2024)** — AI improved idea quality 40%, but evaluators consistently overrated AI output. External cross-model challenge catches overconfidence.

## Principle 5: Independence Before Aggregation

**Mullen et al. (1991)** — Meta-analysis, 800+ teams. Nominal groups (independent then combine) outperform brainstorming by +57%. Production blocking, evaluation apprehension, social loafing degrade groups.

**Surowiecki (2004)** — Wisdom of Crowds requires: diversity, independence, decentralization, aggregation. Three model families = diversity. Independent Round 1 = independence. Lead synthesis = aggregation.

## Principle 6: Match Technique to Complexity

**ERD 2024 / Du et al. 2024** — Round 2 captures ~93% of gains. Rounds 3-5 marginal for most tasks.

**IFEval / FollowBench (ACL 2025)** — Compliance drops ~15-30% per additional constraint. Single-intent passes essential.

**SmartBear/Cisco (3.2M LOC)** — Detection collapses above 400 LOC/session. Optimal: 200-400 LOC.

## Principle 7: Provide Scaffolding, Not Just "Think Harder"

**Fagan (1976)** — Checklist-driven inspection finds significantly more defects than unstructured review.

**PBR Studies** — Structured checklists +25-40% detection over ad-hoc review.

**RoleLLM (ACL 2024)** — Structure beats persona. Task decomposition > role-playing prompts.

**Zhang et al. (2025)** — Prompt compression can IMPROVE performance by removing noise.

## Additional Evidence

**MoA (Together AI 2024)** — 6-model ensemble beat GPT-4o by 7.6% on AlpacaEval. LLMs generate better responses given OTHER models' output, even weaker ones.

**MAST Taxonomy (2025)** — 41-86.7% multi-agent failure rate. 79% from coordination, not tech. Clear roles + hard limits essential.

**AgentCoder (2024)** — Specialized multi-agent: 96.3% HumanEval vs 67% single GPT-4.

**Microsoft SoCC 2022** — Severe incidents are multi-factor across code/config/deploy. Swiss Cheese Model: parallel passes + integration pass.

**Google Tricorder** — Automated static analysis: high actionability at scale. Layer 1 gates.

**AWS Formal Methods (Newcombe et al., CACM)** — TLA+ caught critical distributed bugs testing missed. Critical-tier formal verification mindset.

**TDD (IBM/Microsoft/Ericsson meta-analysis 2012)** — Reduces defects 40-90%. Costs 15-35% more time. Worth it for Critical/High risk.

**Static Typing (Hanenberg et al.)** — Prevents ~15% of bugs. Bigger win: comprehension and refactoring confidence.
