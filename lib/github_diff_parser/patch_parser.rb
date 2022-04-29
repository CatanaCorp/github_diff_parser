# frozen_string_literal: true

require "time"

module GithubDiffParser
  class PatchParser
    # @param git_patch [String] the git format-patch output
    def initialize(git_patch)
      @git_patch = git_patch
      @parsed_patches = []
      @current_patch = nil
      @diff_buffer = +""
      @diff_header_encountered = false
    end

    # Parse and process the git format-patch output
    #
    # @return [Array<GithubDiffParser::Patch>]
    def process
      @git_patch.each_line do |line|
        case line
        when Regexes::PATCH_COMMIT
          parse_current_patch
          process_new_patch(Regexp.last_match)
        when Regexes::DIFF_HEADER
          diff_section_starts(line)
        when Regexes::PATCH_COMMIT_TIMESTAMP
          add_patch_timestamp(Regexp.last_match)
        when "\n"
          # No-op. This signify the start of a new patch section.
        else
          add_line_to_diff_buffer(line)
        end
      end

      parse_current_patch
    end

    private

    # Called when the parser encounter a line `From 21e02a7fd129a0c17e3dfbf39c6e69240c3dc3d2 Mon Sep 17 00:00:00 2001`.
    # This means we are going to process a new patch section and the diff from the current patch
    # can now be parsed.
    def parse_current_patch
      return unless @current_patch

      @current_patch.diffs = GithubDiffParser.parse_diff(@diff_buffer)
      @parsed_patches << @current_patch
    end

    # Called when the parser encounter a line `From 21e02a7fd129a0c17e3dfbf39c6e69240c3dc3d2 Mon Sep 17 00:00:00 2001`.
    # Creates a new Patch object. The associated diff will be parsed once a new patch section starts.
    #
    # @param match_data [MatchData]
    def process_new_patch(match_data)
      @diff_header_encountered = false
      @diff_buffer.clear

      @current_patch = Patch.new(match_data[:commit])
    end

    # Called when the parser encounter a line `diff --git a/app/my_file.rb b/app/my_file.rb`.
    # Any line starting from here will be placed in a buffer. The whole diff section will be
    # parsed once a new Patch starts.
    #
    # @param line [String]
    def diff_section_starts(line)
      @diff_buffer << line

      @diff_header_encountered = true
    end

    # Called when the parser encounter a line `Date: Fri, 15 Apr 2022 12:23:53 +0200`.
    # Set the timestamp on the Patch as a Time object.
    #
    # @param match_data [MatchData]
    def add_patch_timestamp(match_data)
      unless @current_patch
        raise InvalidPatch, "Malformated patch. Expected to encounter the commit SHA before the timestamp"
      end

      @current_patch.timestamp = Time.parse(match_data[:timestamp])
    end

    # @param line [String]
    def add_line_to_diff_buffer(line)
      @diff_buffer << line if @diff_header_encountered
    end
  end
end
