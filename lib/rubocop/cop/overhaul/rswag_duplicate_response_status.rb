# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks that no two `response` blocks share the same HTTP status code
      # within a single rswag operation block. rswag does not merge repeated
      # definitions (e.g. schemas), so duplicate status codes lead to ambiguous
      # API documentation.
      #
      # Use context/describe blocks to write multiple test scenarios for the
      # same response status code.
      #
      # @example
      #   # bad
      #   get "Retrieve users" do
      #     response "200", "users found" do
      #       schema type: :array
      #       run_test!
      #     end
      #
      #     response 200, "empty list" do
      #       schema type: :array
      #       run_test!
      #     end
      #   end
      #
      #   # good
      #   get "Retrieve users" do
      #     response "200", "users found" do
      #       schema type: :array
      #
      #       context "when there are users" do
      #         run_test!
      #       end
      #
      #       context "when the list is empty" do
      #         run_test!
      #       end
      #     end
      #   end
      #
      class RswagDuplicateResponseStatus < RuboCop::Cop::Base
        MSG = "Duplicate `response` block for status `%<status>s`. " \
              "Consolidate into a single `response` block and use context/describe blocks for different scenarios."

        # @!method rswag_operation_block?(node)
        def_node_matcher :rswag_operation_block?, <<~PATTERN
          (block
            (send nil? {:get :post :put :patch :delete :head :options} ...)
            (args)
            _)
        PATTERN

        # @!method response_block_status(node)
        def_node_matcher :response_block_status, <<~PATTERN
          (block
            (send nil? :response ${str int} ...)
            ...)
        PATTERN

        def on_block(node)
          return unless rswag_operation_block?(node)
          return if node.body.nil?

          seen = {}
          node.each_descendant(:block) do |child|
            status_node = response_block_status(child)
            next unless status_node

            status = status_node.value.to_s
            if seen[status]
              add_offense(child.send_node, message: format(MSG, status: status))
            else
              seen[status] = true
            end
          end
        end
      end
    end
  end
end
