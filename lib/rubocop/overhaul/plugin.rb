# frozen_string_literal: true

require "lint_roller"

require_relative "version"

module RuboCop
  module Overhaul
    # A plugin that integrates RuboCop Overhaul with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: "rubocop-overhaul",
          version: VERSION,
          homepage: "https://github.com/over-haul/rubocop-overhaul",
          description: "Base RuboCop configurations and custom cops used at Overhaul."
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = Pathname.new(__dir__).join("../../..")

        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: project_root.join("config/default.yml")
        )
      end
    end
  end
end
