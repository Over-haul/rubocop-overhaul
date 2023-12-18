# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/overhaul"
require_relative "rubocop/overhaul/version"
require_relative "rubocop/overhaul/inject"

RuboCop::Overhaul::Inject.defaults!

require_relative "rubocop/cop/overhaul_cops"
