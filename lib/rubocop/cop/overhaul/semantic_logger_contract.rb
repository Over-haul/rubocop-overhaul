# frozen_string_literal: true

module RuboCop
  module Cop
    module Overhaul
      # Checks logger usage that is incompatible with SemanticLogger contract.
      # See: https://github.com/reidmorrison/semantic_logger/issues/250
      #
      # @example
      #
      # # bad:
      # logger.info(message: "foo", payload: {}, error: StandardError.new)
      #
      # # good:
      # logger.info(message: "foo", error: StandardError.new)
      # logger.info(message: "foo", payload: {}, exception: StandardError.new)
      # logger.info("foo", {}, StandardError.new)
      class SemanticLoggerContract < RuboCop::Cop::Cop
        MSG = "Logger usage incompatible with SemanticLogger. `payload` cannot be used along with arbitrary keywords."

        RESTRICT_ON_SEND = %i[error warn info debug fatal].freeze

        # @see
        # https://github.com/reidmorrison/semantic_logger/blob/v4.14.0/lib/semantic_logger/log.rb#L51-L54
        SEMANTIC_LOGGER_ALLOWED_KEYWORDS = %i[
          message exception backtrace exception
          duration min_duration payload
          log_exception on_exception_level
          metric metric_amount dimensions
        ].to_set.freeze

        def_node_matcher :logger_call, <<~PATTERN
          (send
           _ _
           (hash $...))
        PATTERN

        def on_send(node)
          logger_call(node) do |pairs|
            return unless pairs.any? { |pair| pair.key.value == :payload }

            pairs
              .reject { |pair| SEMANTIC_LOGGER_ALLOWED_KEYWORDS.include?(pair.key.value) }
              .each { |pair| add_offense(pair) }
          end
        end
      end
    end
  end
end
