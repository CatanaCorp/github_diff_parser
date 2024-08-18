# frozen_string_literal: true

module GithubDiffParser
  class Hunk
    # @return [Array<GithubDiffParser::Line>] all the contextual, added and removed lines belonging to this Hunk.
    attr_reader :lines

    # @return [Integer] (see #initialize)
    attr_reader :previous_file_start_line

    # @return [Integer] (see #initialize)
    attr_reader :new_file_start_line

    # @return [String] (see #initialize)
    attr_reader :context

    # @param previous_file_start_line [String] the starting line number of the hunk for the original file
    # @param new_file_start_line [String] the starting line number of the hunk for the new file
    # @param context [String]
    #
    # @example Representation of the previous_file_start_line and new_file_start_line in a Git Diff
    #   @@ -6,5 +6,6 @@ def test1 # => The first 6 is the previous_file_start_line the second is the new_file_start_line
    def initialize(previous_file_start_line, new_file_start_line, context)
      @previous_file_start_line = Integer(previous_file_start_line)
      @new_file_start_line = Integer(new_file_start_line)
      @context = context
      @lines = []
    end

    # Add a line to this Hunk
    #
    # @param line_content [String] the line content itself
    # @param patch_position [Integer] the the position of this line in the patch
    # @param type [Symbol] the type of the line. Can be either :addition, :deletion or :contextual
    def add_line(line_content, patch_position, type:)
      case type
      when :deletion
        number = @previous_file_start_line + contextual_lines.count + deletion_lines.count
        line = Line.new(line_content, number, nil, patch_position, type)
      when :addition
        number = @new_file_start_line + contextual_lines.count + addition_lines.count
        line = Line.new(line_content, nil, number, patch_position, type)
      when :contextual
        before = @previous_file_start_line + contextual_lines.count + deletion_lines.count
        now =  @new_file_start_line + contextual_lines.count + addition_lines.count
        line = Line.new(line_content, before, now, patch_position, type)
      end

      @lines << line
    end

    # Get all the contextual lines for this Hunk.
    #
    # @return [Array<GithubDiffParser::Line>]
    def contextual_lines
      @lines.select(&:contextual?)
    end

    # Get all the addition lines for this Hunk.
    #
    # @return [Array<GithubDiffParser::Line>]
    def addition_lines
      @lines.select(&:addition?)
    end

    # Get all the deletion lines for this Hunk.
    #
    # @return [Array<GithubDiffParser::Line>]
    def deletion_lines
      @lines.select(&:deletion?)
    end

    # Find a line in the Hunk by it's previous line number.
    #
    # @param line_number [Integer]
    #
    # @return [GithubDiffParser::Line, nil]
    def find_previous_line(line_number)
      lines.find { |line| line.previous_number == line_number }
    end

    # Find a line in the Hunk by it's current line number.
    #
    # @param line_number [Integer]
    #
    # @return [GithubDiffParser::Line, nil]
    def find_current_line(line_number)
      lines.find { |line| line.current_number == line_number }
    end

    # The number of lines in the previous version.
    #
    # @example
    #   "@@ +3,4 -3,8 @@" This would return "4"
    #   "@@ +3 -3 @@"     This would return "1"
    def previous_line_count
      contextual_lines.count + deletion_lines.count
    end

    # The number of lines in the new version.
    #
    # @example
    #   "@@ +3,4 -3,8 @@" This would return "8"
    #   "@@ +3 -3 @@"     This would return "1"
    def new_line_count
      contextual_lines.count + addition_lines.count
    end
  end
end
