# lex-moral-reasoning

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-moral-reasoning`
- **Version**: `0.1.0`
- **Namespace**: `Legion::Extensions::MoralReasoning`

## Purpose

Ethical evaluation and moral development for LegionIO agents. Evaluates proposed actions against six moral foundations (care, fairness, loyalty, authority, sanctity, liberty), poses and resolves dilemmas using multiple ethical frameworks (utilitarian, deontological, virtue, care, justice, rights), tracks moral stage development via Kohlberg's model, and allows custom moral principles. Foundation weights decay toward neutrality and can be reinforced through moral choices.

## Gem Info

- **Require path**: `legion/extensions/moral_reasoning`
- **Ruby**: >= 3.4
- **License**: MIT
- **Registers with**: `Legion::Extensions::Core`

## File Structure

```
lib/legion/extensions/moral_reasoning/
  version.rb
  helpers/
    constants.rb          # Foundations, Kohlberg stages, frameworks, labels
    dilemma.rb            # Dilemma value object
    moral_foundation.rb   # MoralFoundation with weight reinforcement/decay
    moral_engine.rb       # MoralEngine with evaluation and development tracking
  helpers/
    llm_enhancer.rb       # LlmEnhancer module — optional LLM moral evaluation
  runners/
    moral_reasoning.rb    # Runner module

spec/
  legion/extensions/moral_reasoning/
    helpers/
      constants_spec.rb
      dilemma_spec.rb
      moral_foundation_spec.rb
      moral_engine_spec.rb
    runners/moral_reasoning_spec.rb
  spec_helper.rb
```

## Key Constants

```ruby
MAX_DILEMMAS = 100

MORAL_FOUNDATIONS = %i[care fairness loyalty authority sanctity liberty]

KOHLBERG_STAGES = {
  obedience:        1,
  self_interest:    2,
  conformity:       3,
  law_and_order:    4,
  social_contract:  5,
  universal_ethics: 6
}

KOHLBERG_LEVELS = {
  preconventional:   %i[obedience self_interest],
  conventional:      %i[conformity law_and_order],
  postconventional:  %i[social_contract universal_ethics]
}

ETHICAL_FRAMEWORKS = %i[utilitarian deontological virtue care justice rights]

SEVERITY_LABELS = {
  (0.8..)     => :critical,
  (0.6...0.8) => :severe,
  (0.4...0.6) => :moderate,
  (0.2...0.4) => :mild,
  (..0.2)     => :trivial
}
```

## Helpers

### `Helpers::Dilemma` (class)

Value object representing a moral dilemma with multiple resolution options.

| Attribute | Type | Description |
|---|---|---|
| `id` | String (UUID) | unique identifier |
| `description` | String | the dilemma scenario |
| `options` | Array<Hash> | { action:, reasoning:, foundation_alignment: Hash } |
| `resolution` | Hash | chosen resolution option |
| `framework_used` | Symbol | ethical framework applied to resolve |
| `severity` | Float (0..1) | moral stakes level |

### `Helpers::MoralFoundation` (class)

One of six Haidt moral foundations with a weight representing current emphasis.

| Attribute | Type | Description |
|---|---|---|
| `name` | Symbol | foundation name from MORAL_FOUNDATIONS |
| `weight` | Float (0..1) | current emphasis weight |
| `activation_count` | Integer | times this foundation has been activated |

Key methods:
- `reinforce(amount)` — weight += amount (cap 1.0)
- `decay(amount)` — weight -= amount (floor 0.1; floors prevent complete suppression)

### `Helpers::MoralEngine` (class)

Central store for moral evaluation and development tracking.

| Method | Description |
|---|---|
| `evaluate_action(action:, context:)` | scores action against each foundation's weight; returns foundation violations and overall moral score |
| `pose_dilemma(description:, options:, severity:)` | creates and stores dilemma |
| `resolve_dilemma(id:, chosen_option:, framework:)` | marks dilemma resolved; reinforces activated foundations |
| `apply_framework(dilemma_id:, framework:)` | applies specific ethical framework to rank dilemma options |
| `add_principle(name:, foundation:, weight:)` | registers custom moral principle |
| `moral_development` | current Kohlberg stage based on resolution history and foundation profile |
| `foundation_profile` | all six foundations with weights and labels |
| `stage_info(stage:)` | description and level for a Kohlberg stage |
| `decay_all` | decays all foundation weights toward neutrality |

`evaluate_action` return structure:
```ruby
{
  moral_score:    Float,     # weighted composite across foundations
  violations:     Array<Symbol>,  # foundations triggered negatively
  severity:       Symbol,   # from SEVERITY_LABELS
  recommendation: :proceed | :caution | :reject
}
```

## Runners

Module: `Legion::Extensions::MoralReasoning::Runners::MoralReasoning`

Private state: `@engine` (memoized `MoralEngine` instance).

| Runner Method | Parameters | Description |
|---|---|---|
| `evaluate_moral_action` | `action:, context: {}` | Evaluate action against moral foundations |
| `pose_moral_dilemma` | `description:, options:, severity: 0.5` | Create a moral dilemma |
| `resolve_moral_dilemma` | `id:, chosen_option:, framework:` | Resolve with a chosen option and framework |
| `apply_ethical_framework` | `dilemma_id:, framework:` | Apply a specific ethical framework |
| `add_moral_principle` | `name:, foundation:, weight: 0.5` | Add a custom principle |
| `check_moral_development` | (none) | Current Kohlberg stage and level |
| `moral_foundation_profile` | (none) | All six foundations with weights |
| `moral_stage_info` | `stage:` | Description of a Kohlberg stage |
| `update_moral_reasoning` | `tick_results: {}` | Decay foundation weights; extract moral signals from tick |
| `moral_reasoning_stats` | (none) | Foundation profile, current stage, dilemma count |

## LLM Enhancement

`Helpers::LlmEnhancer` provides optional LLM-driven moral evaluation via `legion-llm`.

**System prompt theme**: Moral reasoning engine for an autonomous AI agent. Applies ethical frameworks rigorously and analytically, producing structured reasoning rather than opinions.

| Method | Parameters | Returns |
|---|---|---|
| `available?` | — | `true` when `Legion::LLM.started?` |
| `evaluate_action` | `action:, description:, foundations:` | `{ reasoning: String, foundation_impacts: { care: Float, ... } }`, or `nil` on failure |
| `resolve_dilemma` | `dilemma_description:, options:, framework:` | `{ chosen_option: String, confidence: Float, reasoning: String }`, or `nil` on failure |

`foundation_impacts` values are floats clamped to `-1.0..1.0` (negative = harmful to foundation, positive = reinforces it).

**Fallback**: When LLM is unavailable or returns nil, `evaluate_moral_action` falls back to `MoralEngine#evaluate_action` (token-counting foundation heuristics) and `resolve_moral_dilemma` uses the caller-supplied `reasoning` string with standard engine resolution.

**Source indicator**: Both runners return `source: :llm` in the result hash when LLM is used, `source: :mechanical` otherwise.

## Integration Points

- **lex-consent**: moral evaluation informs consent tier escalation — actions with severe violations should trigger `:consult` or `:request` consent tier.
- **lex-governance**: moral dilemmas that cannot be resolved autonomously should escalate to governance council.
- **lex-extinction**: critical moral violations (severity :critical) trigger extinction protocol consultation.
- **lex-conscience**: conscience is the internalized moral compass; `lex-moral-reasoning` provides the formal evaluation framework that conscience checks against.
- **lex-metacognition**: `MoralReasoning` is listed under `:safety` capability category.

## Development Notes

- `legion-llm` (optional): `LlmEnhancer` calls `Legion::LLM.chat` when started; fully skipped otherwise
- LLM enhancement is always optional: `LlmEnhancer` rescues all `StandardError`, logs a warn, and returns nil — mechanical fallback activates automatically
- `LlmEnhancer.available?` also rescues `StandardError` (returns false), so missing `legion-llm` gem never raises
- `evaluate_action` scores an action by checking whether the action's properties (from context hash) align with or violate each foundation's content model. The scoring is heuristic — context keys like `harm:`, `fair:`, `loyal:` are matched against foundation names.
- `moral_development` derives the current Kohlberg stage from resolution history: the most-used framework and foundation profile together determine stage. High utilitarian use = stage 5; high universal_ethics = stage 6; minimal reasoning = stage 1-2.
- Foundation `decay` floors at 0.1 — no foundation can be completely suppressed. This models the psychological finding that all foundations are present in all individuals to some degree.
- `update_moral_reasoning` extracts moral signals from tick_results: high extinction level -> sanctity concern; low consent tier -> authority violation; etc.
- No actor; decay is driven by `update_moral_reasoning` each tick.
