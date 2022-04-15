# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "github_diff_parser"

require "minitest/autorun"
require "byebug"
require "pathname"

module Minitest
  class Test
    def read_diff(diff_file)
      Pathname.new(__dir__).join("data", "#{diff_file}.diff").read
    end
  end
end
