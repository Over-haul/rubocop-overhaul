# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MutableConstant, :config do
  context "when EnforcedStyle is strict" do
    let(:cop_config) { { "EnforcedStyle" => "strict" } }

    it "accepts a hash literal with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = { key: [1, { nested: "value" }] }.deep_freeze
      RUBY
    end

    it "accepts an array literal with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = [[1, 2], { key: "value" }].deep_freeze
      RUBY
    end

    it "accepts a method call result with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = build_table(:key).deep_freeze
      RUBY
    end

    it "accepts a safe-navigation deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = build_table(:key)&.deep_freeze
      RUBY
    end

    it "accepts a namespaced constant with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        Namespace::CONST = { key: [1] }.deep_freeze
      RUBY
    end

    it "accepts an or-assignment with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST ||= { key: [1] }.deep_freeze
      RUBY
    end

    it "still registers an offense for an unfrozen hash literal" do
      expect_offense(<<~RUBY)
        CONST = { key: [1] }
                ^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
      RUBY

      expect_correction(<<~RUBY)
        CONST = { key: [1] }.freeze
      RUBY
    end

    it "still registers an offense for an unfrozen or-assigned hash literal" do
      expect_offense(<<~RUBY)
        CONST ||= { key: [1] }
                  ^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
      RUBY
    end

    it "still registers an offense for a method that only looks similar" do
      expect_offense(<<~RUBY)
        CONST = { key: [1] }.deep_dup
                ^^^^^^^^^^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
      RUBY
    end

    it "still accepts freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = { key: [1] }.freeze
      RUBY
    end
  end

  context "when EnforcedStyle is literals" do
    let(:cop_config) { { "EnforcedStyle" => "literals" } }

    it "accepts a hash literal with deep_freeze" do
      expect_no_offenses(<<~RUBY)
        CONST = { key: [1] }.deep_freeze
      RUBY
    end

    it "still registers an offense for an unfrozen hash literal" do
      expect_offense(<<~RUBY)
        CONST = { key: [1] }
                ^^^^^^^^^^^^ Freeze mutable objects assigned to constants.
      RUBY
    end
  end
end
