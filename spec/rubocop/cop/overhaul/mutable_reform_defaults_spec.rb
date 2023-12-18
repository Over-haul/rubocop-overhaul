# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::MutableReformDefaults, :config do
  let(:prefix) { nil }

  shared_examples "mutable, non-callable default" do |o|
    it "registers an offense for #{o}" do
      expect_offense([prefix, <<~RUBY].compact.join("\n"), o: o)
        property :something, default: %{o}
                                      ^{o} Do not use mutable objects as Reform property defaults
      RUBY

      expect_offense([prefix, <<~RUBY].compact.join("\n"), o: o)
        property :something, default: %{o}, populator: ->(fragment:, **) { self.name = "John" }
                                      ^{o} Do not use mutable objects as Reform property defaults
      RUBY

      expect_offense([prefix, <<~RUBY].compact.join("\n"), o: o)
        property :something, populator: ->(fragment:, **) { self.name = "John" }, default: %{o}
                                                                                           ^{o} Do not use mutable objects as Reform property defaults
      RUBY
    end
  end

  shared_examples "immutable or callable default" do |o|
    it "allows #{o} to be registed as a default" do
      source = [prefix, "property :something, default: #{o}"].compact.join("\n")
      expect_no_offenses(source)

      source = [
        prefix,
        "property :something, default: #{o}, populator: ->(fragment:, **) { self.name = 'John' }"
      ].compact.join("\n")
      expect_no_offenses(source)

      source = [
        prefix,
        "property :something, populator: ->(fragment:, **) { self.name = 'John' }, default: #{o}"
      ].compact.join("\n")
      expect_no_offenses(source)
    end
  end

  context "when the frozen string literal comment is missing" do
    it_behaves_like "mutable, non-callable default", '"#{a}"' # rubocop:disable Lint/InterpolationCheck
    it_behaves_like "mutable, non-callable default", "'some string'"
    it_behaves_like "immutable or callable default", "'some string'.freeze"
  end

  context "when the frozen string literal comment is true" do
    let(:prefix) { "# frozen_string_literal: true" }

    context "and ruby > 3.0", :ruby30 do
      it_behaves_like "mutable, non-callable default", '"#{a}"' # rubocop:disable Lint/InterpolationCheck
    end

    context "and ruby < 3.0", :ruby27 do
      it_behaves_like "immutable or callable default", '"#{a}"' # rubocop:disable Lint/InterpolationCheck
    end

    it_behaves_like "immutable or callable default", "'some string'"
  end

  it_behaves_like "immutable or callable default", "true"
  it_behaves_like "immutable or callable default", "false"
  it_behaves_like "immutable or callable default", "nil"
  it_behaves_like "immutable or callable default", "0"
  it_behaves_like "immutable or callable default", "0.5"
  it_behaves_like "immutable or callable default", "a + 5"
  it_behaves_like "immutable or callable default", "a + 5.0"
  it_behaves_like "immutable or callable default", "5 + 5.0"
  it_behaves_like "immutable or callable default", "5.0 + 5.0"
  it_behaves_like "immutable or callable default", "5.0 + 5"
  it_behaves_like "immutable or callable default", "5.0 + a"
  it_behaves_like "immutable or callable default", "[1, 2, 3].freeze"
  it_behaves_like "immutable or callable default", "Namespace::SOME_CONST"
  it_behaves_like "immutable or callable default", ":some_method"
  it_behaves_like "immutable or callable default", "->{ [] }"
  it_behaves_like "immutable or callable default", "Proc.new { [] }"
  it_behaves_like "immutable or callable default", "proc { [] }"
  it_behaves_like "immutable or callable default", "lambda { [] }"
  it_behaves_like "immutable or callable default", "ENV['something']"

  it_behaves_like "mutable, non-callable default", "[]"
  it_behaves_like "mutable, non-callable default", "{}"
  it_behaves_like "mutable, non-callable default", "a"
  it_behaves_like "mutable, non-callable default", "MyObject.new"
end
