# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::SemanticLoggerContract, :config do
  described_class::RESTRICT_ON_SEND.each do |method|
    context "when using `##{method}`" do
      let(:method) { method }

      it "flags a logger usage incompatible with SemanticLogger" do
        expect_offense(<<~RUBY, method: method)
          logger.%{method}(message: "foo", payload: {}, error: e)
                 _{method}                              ^^^^^^^^ Logger usage incompatible with[...]
        RUBY
      end

      it "does not flag logger usage compatible with SemanticLogger" do
        expect_no_offenses(<<~RUBY)
          logger.#{method}(message: "foo", payload: {}, exception: e)
          logger.#{method}("foo", {}, e)
          logger.#{method}("foo", error: e)
          logger.#{method}(message: "foo", error: e)
        RUBY
      end
    end
  end
end
