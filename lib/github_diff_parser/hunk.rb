# frozen_string_literal: true

module GithubDiffParser
  class Hunk
    # @return [Array<GithubDiffParser::Line>] all the contextual, added and removed lines belonging to this Hunk.
    attr_reader :lines

    # @param previous_lino_start [String] the starting line number of the hunk for the original file
    # @param new_lino_start [String] the starting line number of the hunk for the new file
    #
    # @example Representation of the previous_lino_start and new_lino_start in a Git Diff
    #   @@ -6,5 +6,6 @@ def test1 # => The first 6 is the previous_lino_start, the second is the new_lino_start
    def initialize(previous_lino_start, new_lino_start)
      @previous_lino_start = Integer(previous_lino_start)
      @new_lino_start = Integer(new_lino_start)
      @lines = []
    end

    # Add a line to this Hunk
    #
    # @param line_content [String] the line content itself
    # @param type [Symbol] the type of the line. Can be either :addition, :deletion or :contextual
    def add_line(line_content, type:)
      patch_position = @lines.count + 1

      case type
      when :deletion
        number = @previous_lino_start + contextual_lines.count + deletion_lines.count
        line = Line.new(line_content, number, nil, patch_position, type)
      when :addition
        number = @new_lino_start + contextual_lines.count + addition_lines.count
        line = Line.new(line_content, nil, number, patch_position, type)
      when :contextual
        before = @previous_lino_start + contextual_lines.count + deletion_lines.count
        now =  @new_lino_start + contextual_lines.count + addition_lines.count
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
  end
end
