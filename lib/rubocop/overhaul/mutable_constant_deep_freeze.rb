# frozen_string_literal: true

module RuboCop
  module Overhaul
    # Makes Style/MutableConstant accept `deep_freeze` the same as `freeze`.
    #
    # @example EnforcedStyle: strict
    #   # bad
    #   CONST = { key: [1] }
    #
    #   # good
    #   CONST = { key: [1] }.freeze
    #   CONST = { key: [1] }.deep_freeze
    #
    module MutableConstantDeepFreeze
      def on_casgn(node)
        value = node.expression || (node.parent.expression if node.parent&.or_asgn_type?)
        return if deep_freeze_call?(value)

        super
      end

      private

        def deep_freeze_call?(value)
          value&.call_type? && value.method?(:deep_freeze)
        end
    end
  end
end

RuboCop::Cop::Style::MutableConstant.prepend(RuboCop::Overhaul::MutableConstantDeepFreeze)
