# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Flags relation-mutating calls chained after `includes_external`.
      #
      # `includes_external` materializes the relation and caches external association data on each record.
      #
      # Keep `includes_external` after relation-producing calls and before Enumerable methods.
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
        MSG = "Do not chain `%{method}` after `includes_external` — it returns a new " \
              "relation that re-queries without the external preload. Move `%{method}` " \
              "before `includes_external`."

        RELATION_MUTATING_METHODS = %i[
          where not order reorder limit offset joins left_joins left_outer_joins
          group having merge distinct none or unscope select rewhere regroup
          eager_load preload includes references readonly lock from extending
        ].to_set.freeze
        RESTRICT_ON_SEND = RELATION_MUTATING_METHODS.freeze

        def on_send(node)
          return unless RELATION_MUTATING_METHODS.include?(node.method_name)
          return if enumerable_select?(node)
          return unless includes_external_in_receiver_chain?(node.receiver)

          add_offense(node.loc.selector, message: format(MSG, method: node.method_name))
        end
        alias on_csend on_send

        private

          def enumerable_select?(node)
            return false unless node.method?(:select)

            parent = node.parent
            (parent&.any_block_type? && parent.send_node.equal?(node)) || node.first_argument&.block_pass_type?
          end

          def includes_external_in_receiver_chain?(receiver)
            current = receiver
            while current
              current = current.children.first if current.begin_type? && current.children.one?
              return false unless current.call_type? || current.any_block_type?

              call = current.any_block_type? ? current.send_node : current
              return true if call.method?(:includes_external)

              current = call.receiver
            end
            false
          end
      end
    end
  end
end
