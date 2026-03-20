# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::RswagConsumesWithBodyParam, :config do
  context "when a :body parameter is defined without consumes" do
    it "registers an offense on the operation method" do
      expect_offense(<<~RUBY)
        post "Creates a user" do
        ^^^^^^^^^^^^^^^^^^^^^ Add a `consumes` statement when a `:body` parameter is defined.
          parameter name: :user, in: :body, schema: { type: :object }

          response "201", "user created" do
            run_test!
          end
        end
      RUBY
    end

    it "registers an offense for put operations" do
      expect_offense(<<~RUBY)
        put "Updates a user" do
        ^^^^^^^^^^^^^^^^^^^^ Add a `consumes` statement when a `:body` parameter is defined.
          parameter name: :user, in: :body, schema: { type: :object }

          response "200", "user updated" do
            run_test!
          end
        end
      RUBY
    end

    it "registers an offense for patch operations" do
      expect_offense(<<~RUBY)
        patch "Partially updates a user" do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add a `consumes` statement when a `:body` parameter is defined.
          parameter name: :user, in: :body, schema: { type: :object }

          response "200", "user updated" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when a :body parameter is defined with consumes" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        post "Creates a user" do
          consumes "application/json"
          parameter name: :user, in: :body, schema: { type: :object }

          response "201", "user created" do
            run_test!
          end
        end
      RUBY
    end

    it "does not register an offense for other content types" do
      expect_no_offenses(<<~RUBY)
        post "Uploads a file" do
          consumes "multipart/form-data"
          parameter name: :file, in: :body, schema: { type: :object }

          response "201", "file uploaded" do
            run_test!
          end
        end
      RUBY
    end
  end

  context "when no :body parameter is defined" do
    it "does not register an offense when using query parameters only" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          parameter name: :page, in: :query, schema: { type: :integer }

          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end

    it "does not register an offense when using path parameters only" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a user" do
          parameter name: :id, in: :path, schema: { type: :integer }

          response "200", "user found" do
            run_test!
          end
        end
      RUBY
    end

    it "does not register an offense when no parameters are defined" do
      expect_no_offenses(<<~RUBY)
        get "Retrieves a list of users" do
          response "200", "users found" do
            run_test!
          end
        end
      RUBY
    end
  end
end
