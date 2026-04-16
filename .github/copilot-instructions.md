# Copilot Instructions

This gem (`rubocop-overhaul`) provides Overhaul's shared RuboCop configurations and custom cops.

## Common tools

Binstubs are available at the `bin/` directory - prefer using them over `bundle exec` when possible.

We use `rspec` for running tests and `rubocop` for linting Ruby files.

Always ensure all tests are passing and no new linter offenses were reported after making code changes.

## Architecture

- `lib/rubocop-overhaul.rb` — gem entry point; loads all cops and the plugin
- `lib/rubocop/overhaul/plugin.rb` — `LintRoller::Plugin` integration (rubocop >= 1.72)
- `lib/rubocop/cop/overhaul_cops.rb` — requires all individual cop files; **new cops must be added here**
- `lib/rubocop/cop/overhaul/` — individual cop implementations
- `config/default.yml` — cop configuration (enabled/disabled, `Include` patterns, `VersionAdded`); **new cops must have an entry here**
- `oh_defaults/` — shareable RuboCop YAML configs for downstream consumers (`rubocop.yml`, `rubocop-rails.yml`, `rubocop-rspec.yml`, `rubocop-factory_bot.yml`, `rubocop-rswag.yml`)
- `spec/` — mirrors `lib/` directory structure

## Adding a New Cop

The scaffold rake task handles the boilerplate:

```bash
bundle exec rake new_cop[Overhaul/CopName]
```

This generates the cop file, spec file, adds the `require` to `overhaul_cops.rb`, and adds the entry to `config/default.yml`. After scaffolding, fill in:

1. **Cop class** in `lib/rubocop/cop/overhaul/cop_name.rb`:
   - Inherit from `RuboCop::Cop::Base` inside `RuboCop::Cop::Overhaul`
   - Use `def_node_matcher` for AST pattern matching
   - Use `RESTRICT_ON_SEND` to scope `on_send` triggering where applicable
   - Add `@example` with `# bad` / `# good` in the class doc comment
   - Call `add_offense(node)` to register violations
   - Auto-correction support is preferable but not required

2. **Config entry** in `config/default.yml`:
   - `VersionAdded` is not currently used - always set it to `0.0.1` to avoid issues
   - Add `Include` globs if the cop is only relevant to specific file paths

3. **Spec** in `spec/rubocop/cop/overhaul/cop_name_spec.rb`:
   - Use `RSpec.describe ..., :config do` (the `:config` tag is required)
   - Use `expect_offense` / `expect_no_offenses` helpers from `RuboCop::RSpec::ExpectOffense`

## Key Conventions

- Every Ruby source and spec file starts with `# frozen_string_literal: true`
- All custom cops live in the `RuboCop::Cop::Overhaul` module
- RuboCop configs under `oh_defaults/` are modular by audience:
  * Generic RuboCop configurations must go under `oh_defaults/rubocop.yml`
  * RSpec specific configurations must go under `oh_defaults/rubocop-rspec.yml` as they require `rubocop-rspec`
  * Rails specific configurations must go under `oh_defaults/rubocop-rails.yml` as they require `rubocop-rails`
  * FactoryBot specific configurations must go under `oh_defaults/rubocop-factory_bot.yml` as they require `rubocop-factory_bot`
  * rswag specific configurations may go under `oh_defaults/rubocop-rswag.yml` (and they can include cops from any department)
