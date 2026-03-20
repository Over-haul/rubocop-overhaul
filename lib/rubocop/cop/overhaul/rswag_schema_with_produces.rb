# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks that every `response` block has a `schema` definition when
      # `produces "application/json"` applies to it. A `produces` at the
      # operation level applies to all response blocks; a `produces` inside a
      # specific response block applies only to that response block.
      #
      # @example
      #   # bad — produces at operation level, second response has no schema
      #   get "Retrieves a list of users" do
      #     produces "application/json"
      #
      #     response "200", "users found" do
      #       schema type: :array, items: { type: :object }
      #       run_test!
      #     end
      #
      #     response "404", "not found" do
      #       run_test!
      #     end
      #   end
      #
      #   # good — produces at operation level, all responses have schema
      #   get "Retrieves a list of users" do
      #     produces "application/json"
      #
      #     response "200", "users found" do
      #       schema type: :array, items: { type: :object }
      #       run_test!
      #     end
      #   end
      #
      #   # good — produces inside a response block applies only to that block
      #   get "Retrieves a list of users" do
      #     response "200", "users found" do
      #       produces "application/json"
      #       schema type: :array, items: { type: :object }
      #       run_test!
      #     end
      #
      #     response "404", "not found" do
      #       run_test!
      #     end
      #   end
      #
      class RswagSchemaWithProduces < RuboCop::Cop::Base
        MSG = "Add a `schema` definition when `produces \"application/json\"` is specified."

        # @!method rswag_operation_block?(node)
        def_node_matcher :rswag_operation_block?, <<~PATTERN
          (block
            (send nil? {:get :post :put :patch :delete :head :options} ...)
            (args)
            _)
        PATTERN

        # @!method response_block?(node)
        def_node_matcher :response_block?, <<~PATTERN
          (block
            (send nil? :response ...)
            ...)
        PATTERN

        # @!method has_schema_call?(node)
        def_node_matcher :has_schema_call?, <<~PATTERN
          (send nil? :schema ...)
        PATTERN

        # @!method has_produces_json_call?(node)
        def_node_matcher :has_produces_json_call?, <<~PATTERN
          (send nil? :produces (str "application/json") ...)
        PATTERN

        def on_block(node)
          return unless rswag_operation_block?(node)
          return if node.body.nil?

          op_produces = operation_level_produces?(node)

          node.each_descendant(:block) do |response_node|
            next unless response_block?(response_node)

            response_produces = response_node.each_descendant(:send).any? { |s| has_produces_json_call?(s) }
            next unless op_produces || response_produces

            has_schema = response_node.each_descendant(:send).any? { |s| has_schema_call?(s) }
            add_offense(response_node.send_node) unless has_schema
          end
        end

        private

          # Returns true if `produces "application/json"` appears anywhere in
          # the operation block but outside of any `response` block.
          def operation_level_produces?(operation_node)
            operation_node.each_descendant(:send).any? do |send_node|
              has_produces_json_call?(send_node) &&
                send_node.each_ancestor(:block).none? { |anc| response_block?(anc) }
            end
          end
      end
    end
  end
end
