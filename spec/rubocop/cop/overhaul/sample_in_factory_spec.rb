# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::SampleInFactory, :config do
  # The offending snippets are taken from our own factories, one per shape the cop has to catch.
  context "with a random value in a factory" do
    it "registers an offense for a constant" do
      expect_offense(<<~RUBY)
        FactoryBot.define do
          factory :shipment_group do
            kind { ShipmentGroup::KINDS.sample }
                                        ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
          end
        end
      RUBY
    end

    it "registers an offense for an array literal" do
      expect_offense(<<~RUBY)
        factory :power_bi_report_subscription do
          rendering_type { %w[pdf image].sample }
                                         ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense inside a trait" do
      expect_offense(<<~RUBY)
        factory :device_type do
          trait :calamp_ctc do
            name { DeviceType::CTC_DEVICE_TYPES.sample }
                                                ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
          end
        end
      RUBY
    end

    it "registers an offense on a randomised association" do
      expect_offense(<<~RUBY)
        factory :fraudwatch_category do
          association :categorizable, factory: %i[user company].sample
                                                                ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense for a value nested in a hash" do
      expect_offense(<<~RUBY)
        factory :ignition_state_change_shipment_event do
          details { { engine_on: [true, false].sample } }
                                               ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense for `sample` with a count argument" do
      expect_offense(<<~RUBY)
        factory :power_bi_report_subscription do
          days { (1..7).to_a.sample(rand(1..7)) }
                             ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense inside string interpolation" do
      expect_offense(<<~'RUBY')
        factory :company do
          legal_name { "#{Faker::Company.name} #{(1..999_999).to_a.sample}" }
                                                                   ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense for a safe-navigated `sample`" do
      expect_offense(<<~RUBY)
        factory :power_bi_report do
          workspace_uuid { AzureConfig.power_bi_workspaces&.sample }
                                                            ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense inside a callback hook" do
      expect_offense(<<~RUBY)
        factory :shipment_group do
          after(:build) { |group| group.kind = ShipmentGroup::KINDS.sample }
                                                                    ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense in a helper outside the factory block" do
      expect_offense(<<~RUBY)
        def random_kind
          ShipmentGroup::KINDS.sample
                               ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end

    it "registers an offense when the chain spans several lines" do
      expect_offense(<<~RUBY)
        factory :device_type do
          name do
            DeviceType::TIVE_DEVICE_TYPES
              .to_a
              .sample
               ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
          end
        end
      RUBY
    end

    it "registers an offense for each `sample` in a chain" do
      expect_offense(<<~RUBY)
        factory :shipment_segment do
          stop { ROUTES.sample.stops.sample }
                                     ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
                        ^^^^^^ Do not use `sample` in factories — test data must be deterministic. Use an explicit value or `sequence`.
        end
      RUBY
    end
  end

  context "with deterministic factories" do
    it "allows a fixed value, traits and sequences" do
      expect_no_offenses(<<~RUBY)
        factory :device_type do
          name { DeviceType::SCI_DEVICE_TYPES.first }
          sequence(:serial) { |n| "SN-\#{n}" }

          trait :calamp_ctc do
            name { DeviceType::CTC_DEVICE_TYPES.first }
          end

          traits_for_enum :name, DeviceType::SCI_DEVICE_TYPES
        end
      RUBY
    end

    it "allows an attribute named `sample`" do
      expect_no_offenses(<<~RUBY)
        factory :sensor_reading do
          sample { 21.5 }
          sample_taken_at { Time.zone.local(2026, 1, 1) }
        end
      RUBY
    end

    it "allows a receiverless `sample` reference from another attribute" do
      expect_no_offenses(<<~RUBY)
        factory :sensor_reading do
          sample { association(:sensor_sample) }
          unit { sample.unit }
        end
      RUBY
    end

    it "allows an attribute named `sample` read through `self`" do
      expect_no_offenses(<<~RUBY)
        factory :sensor_reading do
          sample { association(:sensor_sample) }
          unit { self.sample.unit }
        end
      RUBY
    end
  end

  describe "the shipped Include globs" do
    let(:globs) { RuboCop::ConfigLoader.load_file("config/default.yml").for_cop(described_class)["Include"] }

    def match?(path)
      globs.any? { |glob| RuboCop::PathUtil.match_path?(glob, path) }
    end

    # Every factory layout in use across our Ruby repos, one path per layout.
    %w[
      spec/factories/shipments.rb
      spec/factories/pipe_messages/fleets.rb
      factories/shipments.rb
      lib/asset_management/client/testing/factories/asset.rb
      lib/device_management/client/factories/device.rb
      spec/support/asset_management/client/factories/asset.rb
    ].each do |path|
      it "inspects #{path}" do
        expect(match?(path)).to be(true)
      end
    end

    # FactoryBot configuration, and `app/factories` holding factory-pattern classes rather than FactoryBot definitions.
    %w[
      spec/support/factory_bot.rb
      spec/rails_helper.rb
      app/models/shipment.rb
      app/factories/shipment_factory.rb
      app/services/factories/document_factory.rb
      app/lib/factories/document_factory.rb
    ].each do |path|
      it "ignores #{path}" do
        expect(match?(path)).to be(false)
      end
    end
  end
end
