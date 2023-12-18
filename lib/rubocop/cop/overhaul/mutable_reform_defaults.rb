# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks whether a Reform property default isn't a mutable object or
      # a callable object.
      # Implementation is somewhat based on the MutableConstant cop (strict
      # mode).
      #
      # @example
      #   # bad
      #   class Create < Reform::Form
      #     property :name, default: []
      #   end
      #
      #   # good
      #   class Create < Reform::Form
      #     property :name, default: ->{ [] }
      #   end
      #
      #   class Create < Reform::Form
      #     property :name, default: :my_method
      #
      #     def my_method
      #       []
      #     end
      #   end
      #
      class MutableReformDefaults < RuboCop::Cop::Cop
        include FrozenStringLiteral

        MSG = "Do not use mutable objects as Reform property defaults"

        RESTRICT_ON_SEND = %i[property collection].freeze

        def_node_matcher :operation_produces_immutable_object?, <<~PATTERN
          {
            (const _ _)
            (send (const {nil? cbase} :Struct) :new ...)
            (block (send (const {nil? cbase} :Struct) :new ...) ...)
            (send _ :freeze)
            (send {float int} {:+ :- :* :** :/ :% :<<} _)
            (send _ {:+ :- :* :** :/ :%} {float int})
            (send _ {:== :=== :!= :<= :>= :< :>} _)
            (send (const {nil? cbase} :ENV) :[] _)
            (or (send (const {nil? cbase} :ENV) :[] _) _)
            (send _ {:count :length :size} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
        PATTERN

        def_node_matcher :reform_mutable_property_default, <<~PATTERN
          (send nil? /property|collection/
           (sym _)
           (hash
             <(pair (sym :default) $_) ...>
           ))
        PATTERN

        def on_send(node)
          reform_mutable_property_default(node) do |value|
            next if value.block_type?
            next if value.immutable_literal?
            next if operation_produces_immutable_object?(value)
            next if frozen_string_literal?(value)

            add_offense(value)
          end
        end
      end
    end
  end
end
