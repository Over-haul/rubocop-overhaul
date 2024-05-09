# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::FactoryBoundaries, :config do
  let(:cop_config) do
    { "Factories" => { "apple" => ["**/food_service/**"] } }
  end

  shared_examples "usage of factory outside permitted paths" do
    it "flags use of factory outside permitted paths" do
      expect_offense(<<~RUBY, "spec/other_service/fac_spec.rb", method: method)
        %{method}(:apple)
        _{method} ^^^^^^ Do not use this cop here
      RUBY
    end
  end

  shared_examples "usage of factory inside permitted paths" do
    it "does not flag usage of factory in permitted paths" do
      expect_no_offenses(<<~RUBY, "spec/food_service/fac_spec.rb")
        #{method}(:apple)
      RUBY
    end
  end

  described_class::RESTRICT_ON_SEND.flat_map { |method| [method, "FactoryBot.#{method}"] }.each do |method|
    context "when method is #{method}" do
      let(:method) { method.to_s }

      context "when a factory is configured with globs" do
        include_examples "usage of factory outside permitted paths"
        include_examples "usage of factory inside permitted paths"
      end

      context "when a factory is configured with absolute path" do
        let(:cop_config) do
          { "Factories" => { "apple" => ["spec/food_service/fac_spec.rb"] } }
        end

        include_examples "usage of factory outside permitted paths"
        include_examples "usage of factory inside permitted paths"
      end
    end
  end

  it "ignores non-related method calls" do
    expect_no_offenses(<<~RUBY, "spec/other_service/fac_spec.rb")
      custom_create(:apple)
    RUBY
  end
end
