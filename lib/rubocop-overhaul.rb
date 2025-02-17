# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/overhaul"
require_relative "rubocop/overhaul/version"
require_relative "rubocop/overhaul/plugin"

require_relative "rubocop/cop/overhaul_cops"

# Soft dependency on rubocop-rspec >= 3.0
RuboCop::ConfigLoaderResolver.prepend(
  Module.new do
    def resolve_inheritance_from_gems(hash)
      if (loaded_configs = hash.dig("inherit_gem", "rubocop-overhaul")) &&
          loaded_configs.any? { |config| config.end_with?("oh_defaults/rubocop-rspec.yml") } &&
          Gem.loaded_specs["rubocop-rspec"].version < Gem::Version.new("3.0.0")
        raise "rubocop-overhaul requires rubocop-rspec >= 3.0"
      end

      super
    end
  end
)
