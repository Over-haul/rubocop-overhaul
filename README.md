# rubocop-overhaul

Base Rubocop configurations used at Overhaul.

## Installation

Add to your Gemfile:

```ruby
group :development
  gem 'rubocop', require: false
  gem "rubocop-overhaul", github: "Over-haul/rubocop-overhaul", require: false
end
```

On your rubocop configuration:

```yml
inherit_gem:
  rubocop-overhaul:
    - rubocop.yml
    - rubocop-rails.yml # optional
    - rubocop-rspec.yml # optional
```
