# frozen_string_literal: true

module GithubDiffParser
  class Line
    # @return [String] the line content itself
    attr_reader :content

    # @return [Integer] the previous line number before the changes. This match
    #   the number shown by GitHub on the left side when reviewing a Pull Request in split mode.
    attr_reader :previous_number

    # @return [Integer] the current line number before the changes. This match
    #   the number shown by GitHub on the right side when reviewing a Pull Request in split mode.
    attr_reader :current_number

    # @return [Integer] the position of this line in the patch. When using the GitHub API and
    #   you want to write a comment on a given line change, you'll use this.
    attr_reader :patch_position

    # @param content [String] the line content itself
    # @param previous_number [Ingeter] (see #previous_number)
    # @param current_number [Ingeter] (see #current_number)
    # @param patch_position [Ingeter] (see #patch_position)
    # @param type [Symbol] the type of the line. Can be either :addition, :deletion or :contextual
    def initialize(content, previous_number, current_number, patch_position, type)
      @content = content
      @previous_number = previous_number
      @current_number = current_number
      @patch_position = patch_position
      @type = type
    end

    # Check if this line is a contextual line. A contextual line in a Git diff always start with a space (" ")
    #
    # @return [Boolean]
    def contextual?
      @type == :contextual
    end

    # Check if this line is an addition line. An addition line in a Git diff always start with a plus ("+")
    #
    # @return [Boolean]
    def addition?
      @type == :addition
    end

    # Check if this line is a deletion line. A deletion line in a Git diff always start with a minus ("-")
    #
    # @return [Boolean]
    def deletion?
      @type == :deletion
    end
  end
end
