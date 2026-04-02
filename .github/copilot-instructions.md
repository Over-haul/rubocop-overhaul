# Copilot Instructions

This gem (`rubocop-overhaul`) provides Overhaul's shared RuboCop configurations and custom cops.

## Commands

```bash
bundle exec rake              # run full suite: specs + rubocop lint
bundle exec rake spec         # run tests only
bundle exec rake rubocop      # run lint only
bundle exec rspec spec/rubocop/cop/overhaul/some_cop_spec.rb  # run a single spec file
bundle exec rake new_cop[Overhaul/CopName]  # scaffold a new cop
```

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
   - Use `RESTRICT_ON_SEND` (or `RESTRICT_ENUM_METHODS` for block cops) to scope triggering
   - Add `@example` with `# bad` / `# good` in the class doc comment
   - Call `add_offense(node)` to register violations

2. **Config entry** in `config/default.yml`:
   - Set `VersionAdded` to the next gem version
   - Add `Include` globs if the cop is only relevant to specific file paths

3. **Spec** in `spec/rubocop/cop/overhaul/cop_name_spec.rb`:
   - Use `RSpec.describe ..., :config do` (the `:config` tag is required)
   - Use `expect_offense` / `expect_no_offenses` helpers from `RuboCop::RSpec::ExpectOffense`

## Key Conventions

- Every file starts with `# frozen_string_literal: true`
- All custom cops live in the `RuboCop::Cop::Overhaul` module
- Specs run in random order; do not rely on execution order
- `rubocop-rspec >= 3.0` is required when consuming `oh_defaults/rubocop-rspec.yml` (enforced at load time in the entry point)
- The gem is tested against Ruby 3.0–3.4 in CI, though `required_ruby_version` is `>= 2.7`
