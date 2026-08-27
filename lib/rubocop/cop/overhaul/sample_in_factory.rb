# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Flags `sample` calls in factory definitions.
      #
      # Random values make a spec pass locally and fail in CI with no code change.
      #
      # Set an explicit default, move alternatives into traits, or use `sequence` when values must differ.
      #
      # `sample` with no receiver or on `self` is an attribute, not `Array#sample`, so it is left alone.
      #
      # @example
      #   # bad
      #   factory :ignition_state_change_shipment_event do
      #     details { { engine_on: [true, false].sample } }
      #
      #     trait :off do
      #       details { { engine_on: false } }
      #     end
      #   end
      #
      #   # good — pick one of the traits as the default
      #   factory :ignition_state_change_shipment_event do
      #     details { { engine_on: false } }
      #
      #     trait :on do
      #       details { { engine_on: true } }
      #     end
      #   end
      #
      #   # bad — the object graph itself changes between runs
      #   factory :fraudwatch_category do
      #     name { FraudwatchCategory::NAMES.sample }
      #     association :categorizable, factory: %i[user company].sample
      #   end
      #
      #   # good
      #   factory :fraudwatch_category do
      #     name { FraudwatchCategory::NAMES.first }
      #     association :categorizable, factory: :user
      #
      #     traits_for_enum :name, FraudwatchCategory::NAMES
      #   end
      #
      class SampleInFactory < RuboCop::Cop::Base
        MSG = "Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`."

        RESTRICT_ON_SEND = %i[sample].freeze

        def on_send(node)
          return if node.receiver.nil? || node.receiver.self_type?

          add_offense(node.loc.selector)
        end
        alias on_csend on_send
      end
    end
  end
end
