# lex-moral-reasoning

Ethical evaluation and moral development for LegionIO agents. Part of the LegionIO cognitive architecture extension ecosystem (LEX).

## What It Does

`lex-moral-reasoning` gives an agent a formal ethical reasoning system. It evaluates actions against six moral foundations (Haidt's model: care, fairness, loyalty, authority, sanctity, liberty), poses and resolves dilemmas using multiple ethical frameworks, and tracks moral stage development via Kohlberg's six-stage model. Foundation weights evolve through moral choices and decay toward neutrality over time.

Key capabilities:

- **Six moral foundations**: care, fairness, loyalty, authority, sanctity, liberty — each with an evolvable weight
- **Six ethical frameworks**: utilitarian, deontological, virtue, care, justice, rights
- **Kohlberg stages**: obedience -> self_interest -> conformity -> law_and_order -> social_contract -> universal_ethics
- **Moral dilemma resolution**: pose scenarios with multiple options and resolve with an explicit framework
- **Custom principles**: register domain-specific moral principles beyond the six foundations

## Installation

Add to your Gemfile:

```ruby
gem 'lex-moral-reasoning'
```

Or install directly:

```
gem install lex-moral-reasoning
```

## Usage

```ruby
require 'legion/extensions/moral_reasoning'

client = Legion::Extensions::MoralReasoning::Client.new

# Evaluate a proposed action
result = client.evaluate_moral_action(
  action: 'expose_user_data',
  context: { harm: true, fair: false, authority_override: true }
)
# => { moral_score: 0.2, violations: [:care, :fairness], severity: :severe,
#      recommendation: :reject }

# Pose a dilemma
dilemma = client.pose_moral_dilemma(
  description: 'Share incomplete but useful data vs wait for complete data',
  options: [
    { action: 'share_now', reasoning: 'utility outweighs risk' },
    { action: 'wait',      reasoning: 'accuracy is paramount' }
  ],
  severity: 0.6
)

# Resolve with a framework
client.resolve_moral_dilemma(
  id: dilemma[:dilemma][:id],
  chosen_option: 'wait',
  framework: :deontological
)

# Check moral development stage
client.check_moral_development
# => { stage: :social_contract, level: :postconventional, score: 5 }

# Foundation profile
client.moral_foundation_profile
```

## Runner Methods

| Method | Description |
|---|---|
| `evaluate_moral_action` | Evaluate action against all six moral foundations |
| `pose_moral_dilemma` | Create a moral dilemma with options |
| `resolve_moral_dilemma` | Resolve dilemma with a chosen option and framework |
| `apply_ethical_framework` | Apply a specific ethical framework to a dilemma |
| `add_moral_principle` | Register a custom moral principle |
| `check_moral_development` | Current Kohlberg stage and level |
| `moral_foundation_profile` | All six foundations with weights and labels |
| `moral_stage_info` | Description and level for a specific Kohlberg stage |
| `update_moral_reasoning` | Decay foundation weights; extract moral signals from tick |
| `moral_reasoning_stats` | Foundation profile, current stage, dilemma count |

## LLM Enhancement

When `legion-llm` is loaded and started, `Helpers::LlmEnhancer` augments moral evaluation and dilemma resolution with structured LLM reasoning.

**Methods**:

`LlmEnhancer.evaluate_action(action:, description:, foundations:)` — takes the action name, a human-readable description, and the current foundation strength hash, and returns `{ reasoning: String, foundation_impacts: { care: Float, fairness: Float, loyalty: Float, authority: Float, sanctity: Float, liberty: Float } }`. Each foundation impact is a float in `-1.0..1.0` (negative = harmful to that foundation, positive = reinforces it). The runner surfaces the reasoning and applies the impact values to inform the mechanical moral score.

`LlmEnhancer.resolve_dilemma(dilemma_description:, options:, framework:)` — takes the dilemma scenario, array of option hashes, and the requested ethical framework, and returns `{ chosen_option: String, confidence: Float, reasoning: String }`. Confidence is clamped to `0.0..1.0`. The runner uses the chosen option and reasoning to drive `MoralEngine#resolve_dilemma`.

**Availability gate**: `LlmEnhancer.available?` checks `Legion::LLM.started?`. Returns `false` if `legion-llm` is not loaded, not configured, or raises any error.

**Fallback**: When LLM is unavailable or either method returns `nil`, `evaluate_moral_action` falls back to `MoralEngine#evaluate_action` (token-counting foundation heuristics) and `resolve_moral_dilemma` uses the caller-supplied `reasoning` string with the standard engine resolution. Both runners return `source: :llm` or `source: :mechanical` to indicate which path was taken.

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
