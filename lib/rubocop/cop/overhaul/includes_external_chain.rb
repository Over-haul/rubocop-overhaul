# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Flags relation-mutating calls chained after `includes_external`.
      #
      # `includes_external` materializes the relation and caches external
      # association data on each record via `instance_variable_set`. Any
      # subsequent relation-mutating call (`where`, `order`, `joins`, ...)
      # returns a new relation that re-queries the DB without the cached
      # external data, silently dropping the preload and yielding wrong
      # results.
      #
      # Reorder so `includes_external` is the final relation-producing call
      # in the chain, before iteration/Enumerable methods.
      #
      # @example
      #   # bad
      #   Fleet.includes_external(:am_asset)
      #        .where(shipment_segment_id: ids)
      #        .select { |f| f.am_asset&.tractor? }
      #
      #   # good
      #   Fleet.where(shipment_segment_id: ids)
      #        .includes_external(:am_asset)
      #        .select { |f| f.am_asset&.tractor? }
      #
      class IncludesExternalChain < RuboCop::Cop::Base
        MSG = "Do not chain `%<method>s` after `includes_external` — it returns a new " \
              "relation that re-queries without the external preload. Move `%<method>s` " \
              "before `includes_external`."

        RELATION_MUTATING_METHODS = %i[
          where not order reorder limit offset joins left_joins left_outer_joins
          group having merge distinct none or unscope select rewhere regroup
          eager_load preload includes references readonly lock from extending
        ].to_set.freeze

        # `select` is in the list above because `.select(:col1, :col2)` (no block,
        # symbol/string args) is the AR projection variant — it returns a relation
        # and re-queries. `select { |x| ... }` is Enumerable and is fine; we detect
        # the block form and skip it.

        def on_send(node)
          return unless RELATION_MUTATING_METHODS.include?(node.method_name)
          return if enumerable_select_with_block?(node)
          return unless includes_external_in_receiver_chain?(node.receiver)

          add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
        end
        alias on_csend on_send

        private

          def enumerable_select_with_block?(node)
            return false unless node.method?(:select)

            parent = node.parent
            parent&.block_type? && parent.send_node.equal?(node)
          end

          def includes_external_in_receiver_chain?(receiver)
            current = receiver
            while current
              return false unless current.send_type? || current.csend_type? || current.block_type?

              call = current.block_type? ? current.send_node : current
              return true if call.method?(:includes_external)

              current = call.receiver
            end
            false
          end
      end
    end
  end
end
