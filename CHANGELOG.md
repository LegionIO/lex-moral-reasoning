# Changelog

## [0.1.1] - 2026-03-14

### Added
- Optional LLM enhancement via Helpers::LlmEnhancer — `evaluate_action(action:, description:, foundations:)` evaluates moral actions with structured reasoning across all six moral foundations, returning `{ reasoning: String, foundation_impacts: { care: Float, ... } }` with per-foundation impact floats clamped to `-1.0..1.0`. `resolve_dilemma(dilemma_description:, options:, framework:)` resolves moral dilemmas using the specified ethical framework, returning `{ chosen_option: String, confidence: Float, reasoning: String }`. Both methods gate on `Legion::LLM.started?` and fall back to the foundation-weight heuristic scoring built into `MoralEngine` when LLM is unavailable.

## [0.1.0] - 2026-03-13

### Added
- Initial release
