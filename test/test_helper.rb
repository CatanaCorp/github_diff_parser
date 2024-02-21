# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "github_diff_parser"

require "minitest/autorun"
require "byebug"
require "pathname"

module Minitest
  class Test
    def read_diff(diff_file)
      read_fixture("#{diff_file}.diff")
    end

    def read_fixture(fixture)
      Pathname.new(__dir__).join("data", fixture).read
    end
  end
end
