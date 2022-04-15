# frozen_string_literal: true

require_relative "github_diff_parser/version"

module GithubDiffParser
  InvalidDiff = Class.new(ArgumentError)

  autoload :Parser,  "github_diff_parser/parser"
  autoload :Regexes, "github_diff_parser/regexes"
  autoload :Diff,    "github_diff_parser/diff"
  autoload :Hunk,    "github_diff_parser/hunk"
  autoload :Line,    "github_diff_parser/line"

  extend self

  # Parse the output of a unified Git Diff.
  #
  # @param string [String] the output of a Git Diff
  # @raise [GithubDiffParser::InvalidDiff] if the +string+ is not
  #   a correctly formatter Git Diff.
  #
  # @return [Array<GitubDiffParser::Diff>]
  def parse(string)
    Parser.new(string).process
  end
end
