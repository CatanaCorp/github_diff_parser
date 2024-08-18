# frozen_string_literal: true

module GithubDiffParser
  class Parser
    # @param git_diff [String] the Git Diff output
    def initialize(git_diff)
      @git_diff = git_diff
      @parsed_diffs = []
      @current_diff = nil
    end

    # Parse and process the Git Diff output.
    #
    # @return [Array<GithubDiffParser::Diff>]
    # @raise [GithubDiffParser::InvalidDiff] if the Diff output is malformatted
    def process
      @git_diff.each_line do |line|
        case line
        when Regexes::DIFF_HEADER
          process_new_diff(Regexp.last_match)
        when Regexes::INDEX_HEADER
          process_index(Regexp.last_match)
        when Regexes::MODE_HEADER
          process_diff_file_mode(Regexp.last_match)
        when Regexes::ORIGINAL_FILE_HEADER, Regexes::NEW_FILE_HEADER
          validate_diff
        when Regexes::RANGE_HEADER
          add_hunk_to_diff(Regexp.last_match)
        when Regexes::LINE_DIFF
          add_line_to_hunk(Regexp.last_match)
        when Regexes::NO_NEWLINE_AT_EOF
          @current_diff.lines.last.content.sub!(/\n$/, "")
        end
      end

      validate_diff

      @parsed_diffs << @current_diff
    end

    private

    # Called when encountering a `diff --git a/file b/file` in the Git Diff output.
    # Worth to note that a Git Diff output will most likely contain multiple diff section. Each will
    # be represented by a new GithubDiffParser::Diff object.
    #
    # @param match_data [MatchData]
    def process_new_diff(match_data)
      @parsed_diffs << @current_diff if @current_diff

      @current_diff = Diff.new(match_data[:previous_filename], match_data[:new_filename])
    end

    # Called when encountering a `index abc..def` in the Git Diff output.
    #
    # @param match_data [MatchData]
    def process_index(match_data)
      validate_diff

      @current_diff.previous_index = match_data[:previous_index]
      @current_diff.new_index = match_data[:new_index]
      @current_diff.mode ||= Diff::Mode.new("modified", match_data[:bits])
    end

    # Called when encountering a `new file mode 100644` or `delete file mode 100644` in the Git Diff output.
    #
    # @param match_data [MatchData]
    #
    # @raise [GithubDiffParser::InvalidDiff] if the parser didn't process the `diff --git` header first.
    def process_diff_file_mode(match_data)
      validate_diff

      @current_diff.mode = Diff::Mode.new(match_data[:file_mode], match_data[:bits])
    end

    # Called when encountering a `@@ -0,0 +1,10 @@` in the Git Diff output.
    #
    # @param match_data [MatchData]
    #
    # @raise [GithubDiffParser::InvalidDiff] if the parser didn't process the `diff --git` header first.
    def add_hunk_to_diff(match_data)
      validate_diff

      @current_diff.add_hunk(match_data[:previous_lino_start], match_data[:new_lino_start], match_data[:context])
    end

    # Called when encountering a `-text` or `+text` or ` text` in the Git Diff output.
    #
    # @param match_data [MatchData]
    #
    # @raise [GithubDiffParser::InvalidDiff] if the parser didn't process the `diff --git` header first.
    def add_line_to_hunk(match_data)
      validate_diff

      @current_diff.add_line(match_data[:line], type: map_line_type(match_data[:type]))
    end

    # Validate that the Git Diff output contains a `diff --git header` before attempting to add Hunk or Lines
    #
    # @raise [GithubDiffParser::InvalidDiff]
    def validate_diff
      message = "Couldn't find the Git diff header. A valid git diff has to start with 'diff --git'"

      raise InvalidDiff, message if @current_diff.nil?
    end

    # Map the type of the line.
    #
    # @param token [String] either '+', '-' or ' '
    #
    # @raise [GithubDiffParser::InvalidDiff] if a line starts with a unknown token
    def map_line_type(token)
      mapping = { "+" => :addition, "-" => :deletion, " " => :contextual }

      mapping.fetch(token)
    rescue KeyError
      raise InvalidDiff, "Unexpected token: '#{token}' found at beginning of line. Expecting '+', '-', ' '"
    end
  end
end
