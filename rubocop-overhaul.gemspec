# frozen_string_literal: true

require_relative "lib/rubocop/overhaul/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-overhaul"
  spec.version = RuboCop::Overhaul::VERSION
  spec.authors = ["Overhaul"]
  spec.email = ["gems@over-haul.com"]

  spec.summary = "Overhaul's base styleguide"
  spec.description = "Gem containing Overhaul's base rubocop configurations"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "source_code_uri" => "https://github.com/Over-haul/rubocop-overhaul",
    "github_repo" => "https://github.com/Over-haul/rubocop-overhaul",
    "allowed_push_host" => "https://rubygems.pkg.github.com/Over-haul",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["{lib,config,oh_defaults}/**/*"]

  spec.add_dependency "rubocop", "~> 1.40"
end
