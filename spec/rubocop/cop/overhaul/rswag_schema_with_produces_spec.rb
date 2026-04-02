# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::RswagSchemaWithProduces, :config do
  context "when produces is defined at the operation level" do
    context "and a response block has no schema" do
      it "registers an offense on that response block" do
        expect_offense(<<~RUBY)
          get "Retrieves a list of users" do
            tags "Users"
            produces "application/json"

            response "200", "users found" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `schema` definition when `produces "application/json"` is specified.
              run_test!
            end
          end
        RUBY
      end

      it "registers an offense for post operations" do
        expect_offense(<<~RUBY)
          post "Creates a user" do
            produces "application/json"

            response "201", "user created" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `schema` definition when `produces "application/json"` is specified.
              run_test!
            end
          end
        RUBY
      end

      it "registers an offense only on the response blocks that are missing schema" do
        expect_offense(<<~RUBY)
          get "Retrieve users" do
            produces "application/json"

            response "200", "users found" do
              schema type: :array, items: { type: :object }
              run_test!
            end

            response "404", "not found" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `schema` definition when `produces "application/json"` is specified.
              run_test!
            end
          end
        RUBY
      end
    end

    context "and all response blocks have schema" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          get "Retrieves a list of users" do
            produces "application/json"

            response "200", "users found" do
              schema type: :array, items: { type: :object }
              run_test!
            end
          end
        RUBY
      end
    end
  end

  context "when produces is defined inside a response block" do
    it "does not register an offense on that response block when schema is present" do
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

    it "does not register an offense on other response blocks that lack schema" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          response "200", "users found" do
            produces "application/json"
            schema type: :array, items: { type: :object }
            run_test!
          end

          response "404", "not found" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when neither produces nor schema is defined" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when schema is defined inside a response block without produces" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          response "200", "users found" do
            schema type: :array, items: { type: :object }
            run_test!
          end
        end
      RUBY
    end
  end
end
