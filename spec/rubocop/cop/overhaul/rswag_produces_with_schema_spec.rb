# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::RswagProducesWithSchema, :config do
  context "when schema is defined inside a response block without produces" do
    it "registers an offense on the operation method" do
      expect_offense(<<~RUBY)
        get "Retrieves a list of users" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add `produces "application/json"` when a `schema` is defined.
          tags "Users"

          response "200", "users found" do
            schema type: :array, items: { type: :object }
            run_test!
          end
        end
      RUBY
    end

    it "registers an offense for post operations" do
      expect_offense(<<~RUBY)
        post "Creates a user" do
        ^^^^^^^^^^^^^^^^^^^^^ Add `produces "application/json"` when a `schema` is defined.
          response "201", "user created" do
            schema type: :object, properties: { name: { type: :string } }
            run_test!
          end
        end
      RUBY
    end
  end

  context "when schema is defined inside a response block with produces" do
    it "does not register an offense when produces is at the operation level" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          tags "Users"
          produces "application/json"

          response "200", "users found" do
            schema type: :array, items: { type: :object }
            run_test!
          end
        end
      RUBY
    end

    it "does not register an offense when both produces and schema are inside a response block" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          response "200", "users found" do
            produces "application/json"
            schema type: :array, items: { type: :object }
            run_test!
          end
        end
      RUBY
    end
  end

  context "when no schema is defined" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          tags "Users"

          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when produces is defined without schema" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          produces "application/json"

          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end
  end
end
