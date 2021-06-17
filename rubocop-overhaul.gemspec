# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "rubocop-overhaul"
  spec.version       = "0.0.1"
  spec.authors       = ["Overhaul"]
  spec.email         = ["gems@over-haul.com"]

  spec.summary       = "Overhaul's base styleguide"
  spec.description   = "Gem containing Overhaul's base rubocop configurations"
  spec.license       = "MIT"

  spec.metadata = {
    "allowed_push_host" => "https://rubygems.pkg.github.com/Over-haul"
  }

  spec.files = %w[rubocop.yml rubocop-rspec.yml]

  spec.add_dependency "rubocop", "~> 1.0"
end
