# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::AssignmentInsteadOfComparison, :config do
  shared_examples "block returning comparison" do |block_statements|
    it "allows #{block_statements}" do
      source = "my_arr.#{method} { #{block_statements} }"
      expect_no_offenses(source)
    end
  end

  shared_examples "block returning assignment" do |block_statements|
    it "registers an offense for #{block_statements}" do
      *prefix, o = block_statements.split("; ")
      prefix = prefix.join("; ")
      prefix += "; " if prefix.length.positive?

      expect_offense(<<~RUBY, o: o, block_statements: block_statements, prefix: prefix, method: method)
        my_arr.%{method} { %{block_statements} }
               _{method}   _{prefix}^{o} Do not return an assignment from the block of an Enumerable's search method.
      RUBY
    end
  end

  described_class::RESTRICT_ENUM_METHODS.each do |method|
    context "when method is #{method}" do
      let(:method) { method }

      it_behaves_like "block returning assignment", "x = 3"
      it_behaves_like "block returning assignment", "var = 10; x = 3"

      it_behaves_like "block returning comparison", "x == 3"
      it_behaves_like "block returning comparison", "x = 3; a"
    end
  end
end
