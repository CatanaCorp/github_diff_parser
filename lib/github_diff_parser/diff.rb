# frozen_string_literal: true

module GithubDiffParser
  class Diff
    # @return [String] (see #initialize)
    attr_reader :previous_filename

    # @return [String] (see #initialize)
    attr_reader :new_filename

    # @return [Array<GithubDiffParser::Hunk>] the hunks belonging to this diff
    attr_reader :hunks

    # @private
    attr_writer :file_mode

    # @param previous_filename [String] the original filename. Represented by "diff --git /a filename"
    # @param new_filename [String]      the new filename. Represented by "diff --git /b filename"
    def initialize(previous_filename, new_filename)
      @previous_filename = previous_filename
      @new_filename = new_filename
      @hunks = []
    end

    # Add a Git Hunk to the diff.
    #
    # @param previous_lino_start [String] the starting line number of the hunk for the original file
    # @param new_lino_start [String] the starting line number of the hunk for the new file
    #
    # @example Representation of the previous_lino_start and new_lino_start in a Git Diff
    #   @@ -6,5 +6,6 @@ def test1 # => The first 6 is the previous_lino_start, the second is the new_lino_start
    def add_hunk(previous_lino_start, new_lino_start)
      hunks << Hunk.new(previous_lino_start, new_lino_start)
    end

    # Add a line belonging to the previously processed Git Hunk.
    #
    # @param line_content [String] the line content itself
    # @param type [Symbol] the type of the line. Can be either :addition, :deletion or :contextual
    # @raise [GithubDiffParser::InvalidDiff] if we are trying to add a line but the Diff doesn't contain any Hunk.
    def add_line(line_content, type:)
      last_hunk = hunks.last
      raise InvalidDiff, "Couldn't find the Git diff Range Header." unless last_hunk

      patch_position = hunks.flat_map(&:lines).count + hunks.count

      last_hunk.add_line(line_content, patch_position, type: type)
    end

    # Check if this Diff is set to deleted mode.
    #
    # @example When the diff is set to deleted mode
    #   diff --git a/package.json b/package.json
    #   deleted file mode 100644                  # => This indicates the diff is in deletion mode.
    #   index 3ffb801..0000000
    #   --- a/package.json
    #   +++ /dev/null
    #   @@ -1,11 +0,0 @@
    #   -{
    #
    # @return [Boolean]
    def deleted_mode?
      @file_mode == "deleted"
    end

    # Check if this Diff is set to new mode.
    #
    # @example When the diff is set to new mode
    #   diff --git a/blabla.rb b/blabla.rb
    #   new file mode 100644                     # => This indicate the diff is in new mode.
    #   index 0000000..d3dfbe4
    #   --- /dev/null
    #   +++ b/blabla.rb
    #   @@ -0,0 +1,10 @@
    #   +Hello World
    #
    # @return [Boolean]
    def new_mode?
      @file_mode == "new"
    end

    # Check if this Diff is set to rename mode.
    #
    # @example When the diff is set to rename mode
    #   diff --git a/blabla.rb b/app/my_file.rb
    #   similarity index 100%
    #   rename from blabla.rb
    #   rename to app/my_file.rb
    #
    # @return [Boolean]
    def rename_mode?
      previous_filename != new_filename
    end

    # A utility method that returns the current number of a line who might not be present in the diff.
    # This is useful if you need to keep track of the updated line numbers in a file for every changes.
    #
    # @param line_number [Integer]
    #
    # @return [Integer]
    def previous_line_number_is_now(line_number)
      return line_number unless line_shifted?(line_number)

      applicable_hunk = last_applicable_hunk_for_line(line_number)
      line = applicable_hunk.find_previous_line(line_number)

      if line
        line.current_number
      else
        line_number + last_line_offset(applicable_hunk)
      end
    end

    private

    # Check if a line was shifted. A line is considered shifted if its number is superior to the first hunk's start
    # range.
    #
    # @param line_number [Integer]
    #
    # @return [Boolean]
    def line_shifted?(line_number)
      first_hunk = hunks.first

      line_number > first_hunk.new_file_start_line
    end

    # Find the last hunk that shifts the line. We need the last because we know it's the one that will shift the line
    # the most.
    #
    # @param line_number [Integer]
    #
    # @return [GithubDiffParser::Hunk]
    def last_applicable_hunk_for_line(line_number)
      hunks.reverse_each.find do |hunk|
        line_number >= hunk.previous_file_start_line
      end
    end

    # Calculate the number difference of the last line. This method is called when we can't find the desired line number
    # in the Hunk, which means the line we are searching for is not part of the diff.
    #
    # @param hunk [GithubDiffParser::Hunk]
    #
    # @return [Integer]
    def last_line_offset(hunk)
      last_line = hunk.lines.last

      last_line.current_number - last_line.previous_number
    end
  end
end
