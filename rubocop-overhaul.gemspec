# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "rubocop-overhaul"
  spec.version       = 0.0.1
  spec.authors       = ["Overhaul"]
  spec.email         = ["gems@over-haul.com"]

  spec.summary       = "Overhaul's base styleguide"
  spec.description   = "Gem containing Overhaul's base rubocop configurations"
  spec.license       = "MIT"

  spec.metadata = {
    "source_code_uri" => "https://github.com/Overhaul/ruby-style"
    "allowed_push_host" => "https://rubygems.org"
  }

  spec.files = ["rubucop.yml"]

  spec.add_dependency "rubocop", "~> 1.0"
end
