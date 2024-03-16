# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks whether the used factory is allowed in the current path.
      # Requires configuration.
      #
      # @example
      # # with:
      # # Factories: {}
      # # apple:
      # #   - '**/food_service/**'
      #
      # # bad:
      # spec/car_service/apple_spec.rb
      # create(:apple)
      #
      # # good:
      # spec/food_service/apple_spec.rb
      # create(:apple)
      class FactoryBoundaries < RuboCop::Cop::Cop
        MSG = "Do not use this cop here"

        RESTRICT_ON_SEND = %i[
          attributes_for
          attributes_for_list
          build
          build_list
          build_stubbed
          build_stubbed_list
          create
          create_list
          generate
          generate_list
        ].freeze

        # @!method factory_bot_factory(node)
        def_node_matcher :factory_bot_factory, <<~PATTERN
          (send #factory_call? _
            $(sym _)
            ...
          )
        PATTERN

        # @!method factory_bot?(node)
        def_node_matcher :factory_bot?, <<~PATTERN
          (const nil? :FactoryBot)
        PATTERN

        def on_send(node)
          factory_bot_factory(node) do |value|
            allowed_paths = allowed_paths_for(value.value)
            file_path = expanded_file_path

            return if allowed_paths.nil?
            return if allowed_paths.any? do |path|
              file_path.end_with?(path) || # if it's a relative path
                File.fnmatch(path, expanded_file_path, File::FNM_PATHNAME) # if it's a glob
            end

            add_offense(value)
          end
        end

        def factory_call?(node)
          factory_bot?(node) || node.nil?
        end

        def allowed_paths_for(factory)
          cop_config["Factories"][factory.to_s]
        end

        def expanded_file_path
          File.expand_path(processed_source.file_path)
        end
      end
    end
  end
end
