# Rubocop::Overhaul

Base Rubocop configurations and custom cops used at Overhaul.

## Installation

Install the gem and add to the application's Gemfile by executing:

```ruby
group :development do
  gem 'rubocop', require: false
  source "https://rubygems.pkg.github.com/Over-haul" do
    gem "rubocop-overhaul", require: false
  end
end
```

To enable our custom configuration:
```yml
inherit_gem:
  rubocop-overhaul:
    - oh_defaults/rubocop.yml
    - oh_defaults/rubocop-rails.yml # optional
    - oh_defaults/rubocop-rspec.yml # optional
    - oh_defaults/rubocop-factory_bot.yml # optional
```

## Development

To create a new cop, you can execute:

```bash
bundle exec rake new_cop[Overhaul/SomeCopName]
```

If you need help at creating a custom cop, please have a look at these resources:
- https://evilmartians.com/chronicles/custom-cops-for-rubocop-an-emergency-service-for-your-codebase
- https://dev.to/r7kamura/custom-ruby-cop-in-30-min-5ao8
- https://github.com/r7kamura/rubocop-extension-template
- https://thoughtbot.com/blog/rubocop-custom-cops-for-custom-needs
- https://docs.rubocop.org/rubocop/1.13/development.html
- https://www.fastruby.io/blog/rubocop/code-quality/create-a-custom-rubocop-cop.html
- https://github.com/rubocop/rubocop-extension-generator
- https://dmytrovasin.medium.com/how-to-add-a-custom-cop-to-rubocop-47abf82f820a
- https://github.com/airbnb/ruby/tree/f81ebad738c16783603971eed42a3d9eb6b7630e/rubocop-airbnb/lib/rubocop/cop/airbnb
- https://github.com/charitywater/cw-style/tree/master/lib
- https://gist.github.com/stem/e0f71dc5c31f5187dad739023d7b50bf
