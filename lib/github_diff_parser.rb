# frozen_string_literal: true

require_relative "github_diff_parser/version"

module GithubDiffParser
  InvalidDiff  = Class.new(ArgumentError)
  InvalidPatch = Class.new(ArgumentError)

  autoload :Diff,         "github_diff_parser/diff"
  autoload :DiffParser,   "github_diff_parser/diff_parser"
  autoload :Hunk,         "github_diff_parser/hunk"
  autoload :Line,         "github_diff_parser/line"
  autoload :Patch,        "github_diff_parser/patch"
  autoload :PatchParser,  "github_diff_parser/patch_parser"
  autoload :Regexes,      "github_diff_parser/regexes"

  extend self

  # Parse the output of a unified Git Diff.
  #
  # @param string [String] the output of a Git Diff
  # @raise [GithubDiffParser::InvalidDiff] if the +string+ is not
  #   a correctly formatter Git Diff.
  #
  # @return [Array<GitubDiffParser::Diff>]
  def parse_diff(string)
    DiffParser.new(string).process
  end
  alias_method :parse, :parse_diff

  # Parse the output of a git format-patch. The difference between this method
  # and the +parse_diff+ is that it allows to you to get information for each diff
  # such as the commit sha and the date of the commit.
  #
  # @example A correctly formatted git format-patch output
  #   From 21e02a7fd129a0c17e3dfbf39c6e69240c3dc3d2 Mon Sep 17 00:00:00 2001
  #   From: Edouard CHIN <chin.edouard@gmail.com>
  #   Date: Fri, 15 Apr 2022 12:22:33 +0200
  #   Subject: [PATCH] Line added
  #
  #   ---
  #    app/my_file.rb | 1 +
  #    1 file changed, 1 insertion(+)
  #
  #   diff --git a/app/my_file.rb b/app/my_file.rb
  #   index d3dfbe4..03d99f2 100644
  #   --- a/app/my_file.rb
  #   +++ b/app/my_file.rb
  #   @@ -6,5 +6,6 @@ def test1
  #
  #      def test2
  #        "This file is just added"
  #   +    "This is a new line"
  #      end
  #    end
  #
  # @param string [String] the output of a git format-patch
  #
  # @return [Array<GitubDiffParser::Patch>]
  def parse_patch(string)
    PatchParser.new(string).process
  end
end
