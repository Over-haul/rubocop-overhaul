# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::RswagDuplicateResponseStatus, :config do
  context "when two response blocks share the same string status code" do
    it "registers an offense on the duplicate response block" do
      expect_offense(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end

          response "200", "users found with different schema" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
            run_test!
          end
        end
      RUBY
    end
  end

  context "when two response blocks share the same status code as string and integer" do
    it "registers an offense on the duplicate response block" do
      expect_offense(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end

          response 200, "users found with different schema" do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
            run_test!
          end
        end
      RUBY
    end
  end

  context "when three response blocks share the same status code" do
    it "registers an offense on each duplicate after the first" do
      expect_offense(<<~RUBY)
        get "Retrieve users" do
          response "200", "first" do
            run_test!
          end

          response "200", "second" do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
            run_test!
          end

          response "200", "third" do
          ^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
            run_test!
          end
        end
      RUBY
    end
  end

  context "when a duplicate response is nested inside a context block" do
    it "registers an offense on the nested duplicate response block" do
      expect_offense(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end

          context "when there are no users" do
            response "200", "no users found" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
              run_test!
            end
          end
        end
      RUBY
    end
  end

  context "when response blocks with the same status code are each in separate context blocks" do
    it "registers an offense on the second context's response block" do
      expect_offense(<<~RUBY)
        get "Retrieve users" do
          context "with users" do
            response "200", "users found" do
              run_test!
            end
          end

          context "without users" do
            response "200", "no users found" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Duplicate `response` block for status `200`.[...]
              run_test!
            end
          end
        end
      RUBY
    end
  end

  context "when response blocks have different status codes" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end

          response "404", "not found" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when different operation blocks each have a response with the same status code" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end
        end

        post "Create user" do
          response "200", "user created" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when there is only one response block" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        get "Retrieve users" do
          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end
  end
end
