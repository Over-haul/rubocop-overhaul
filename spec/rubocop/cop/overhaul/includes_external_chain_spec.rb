# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Overhaul::IncludesExternalChain, :config do
  context "with a relation-mutating call after includes_external" do
    it "registers an offense for .where (the PR #28751 case)" do
      expect_offense(<<~RUBY)
        Fleet.includes_external(:am_asset)
             .where(shipment_segment_id: segment_ids)
              ^^^^^ Do not chain `where` after `includes_external` — it returns a new relation that re-queries without the external preload. Move `where` before `includes_external`.
             .select { |f| f.am_asset&.tractor? }
      RUBY
    end

    %i[order reorder limit offset joins left_joins group having distinct none
       merge or unscope preload includes references readonly].each do |method|
      it "registers an offense for .#{method}" do
        expect_offense(<<~RUBY, method: method)
          Fleet.includes_external(:am_asset).%{method}(:x)
                                             ^{method} Do not chain `%{method}` after `includes_external` — it returns a new relation that re-queries without the external preload. Move `%{method}` before `includes_external`.
        RUBY
      end
    end

    it "registers an offense across intermediate Enumerable calls" do
      expect_offense(<<~RUBY)
        Fleet.includes_external(:am_asset).tap { |r| log(r) }.where(id: 1)
                                                              ^^^^^ Do not chain `where` after `includes_external` — it returns a new relation that re-queries without the external preload. Move `where` before `includes_external`.
      RUBY
    end

    it "registers an offense for .select with symbol args (projection)" do
      expect_offense(<<~RUBY)
        Fleet.includes_external(:am_asset).select(:id, :name)
                                           ^^^^^^ Do not chain `select` after `includes_external` — it returns a new relation that re-queries without the external preload. Move `select` before `includes_external`.
      RUBY
    end
  end

  context "with safe chains" do
    it "allows .where BEFORE includes_external" do
      expect_no_offenses(<<~RUBY)
        Fleet.where(shipment_segment_id: segment_ids)
             .includes_external(:am_asset)
             .select { |f| f.am_asset&.tractor? }
      RUBY
    end

    it "allows Enumerable .select with a block after includes_external" do
      expect_no_offenses(<<~RUBY)
        Fleet.includes_external(:am_asset).select { |f| f.am_asset&.tractor? }
      RUBY
    end

    it "allows .each / .map / .find_each / .pluck / .count after includes_external" do
      expect_no_offenses(<<~RUBY)
        Fleet.includes_external(:am_asset).each { |f| f.am_asset }
        Fleet.includes_external(:am_asset).map(&:am_asset)
        Fleet.includes_external(:am_asset).find_each { |f| f.am_asset }
        Fleet.includes_external(:am_asset).pluck(:id)
        Fleet.includes_external(:am_asset).count
        Fleet.includes_external(:am_asset).to_a
        Fleet.includes_external(:am_asset).first
      RUBY
    end

    it "allows .where on a chain that does not include includes_external" do
      expect_no_offenses(<<~RUBY)
        Fleet.includes(:am_asset).where(id: 1)
      RUBY
    end
  end
end
