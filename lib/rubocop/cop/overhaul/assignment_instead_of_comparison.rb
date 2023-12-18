# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks whether the return value of an Enumerator block method (fetch,
      # minmax, group, search and sort methods) isn't an assignment.
      #
      # @example
      #   # bad
      #   my_array.select { |x| x = 4 }
      #
      #   # good
      #   my_array.select { |x| x == 4 }
      #
      class AssignmentInsteadOfComparison < RuboCop::Cop::Cop
        MSG = "Do not return an assignment from the block of an Enumerable's search method."

        RESTRICT_ENUM_METHODS = [
          :take_while, :drop_while, # fetch
          :min, :max, :min_by, :max_by, :minmax_by, # minmax
          :group_by, :partition, :slice_after, :slice_before, :slice_when, :chunk, :chunk_while, # group
          :find, :detect, :find_all, :filter, :select, :find_index, :reject, :uniq_by, # search
          :sort, :sort_by # sort
        ].freeze

        # @!method search_method_calls?(node)
        def_node_matcher :search_method_calls, <<~PATTERN
          (block
            (call _ /#{RESTRICT_ENUM_METHODS.join("|")}/)
            (args ...)
            $...
          )
        PATTERN

        def on_block(node)
          search_method_calls(node) do |value|
            value = value.first
            block_return_operation = value.begin_type? ? value.children.last : value
            next unless block_return_operation.lvasgn_type?

            add_offense(block_return_operation)
          end
        end
      end
    end
  end
end
