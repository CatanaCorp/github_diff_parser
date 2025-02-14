# frozen_string_literal: true

module GithubDiffParser
  class Diff
    Mode = Struct.new(:operation, :bits)

    # @return [String] (see #initialize)
    attr_reader :previous_filename

    # @return [String] (see #initialize)
    attr_reader :new_filename

    # @return [Array<GithubDiffParser::Hunk>] the hunks belonging to this diff
    attr_reader :hunks

    # @return [String] the hash of the previous file. This is indicate in the diff
    #   by the line `index abc..def`. The +abc+ part is the previous_index.
    attr_reader :previous_index

    # @return [String] the hash of the new file. This is indicate in the diff
    #   by the line `index abc..def`. The +def+ part is the previous_index.
    attr_reader :new_index

    # @private
    attr_writer :previous_index, :new_index

    # @private
    attr_accessor :mode

    # @param previous_filename [String] the original filename. Represented by "diff --git /a filename"
    # @param new_filename [String]      the new filename. Represented by "diff --git /b filename"
    def initialize(previous_filename, new_filename)
      @previous_filename = previous_filename
      @new_filename = new_filename
      @hunks = []
    end

    # Get all the lines in this diff. Shortcut for `diff.hunks.each { |h| h.lines }`
    def lines
      hunks.flat_map(&:lines)
    end

    # Add a Git Hunk to the diff.
    #
    # @param previous_lino_start [String] the starting line number of the hunk for the original file
    # @param new_lino_start [String] the starting line number of the hunk for the new file
    #
    # @example Representation of the previous_lino_start and new_lino_start in a Git Diff
    #   @@ -6,5 +6,6 @@ def test1 # => The first 6 is the previous_lino_start, the second is the new_lino_start
    def add_hunk(previous_lino_start, new_lino_start, context)
      hunks << Hunk.new(previous_lino_start, new_lino_start, context)
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
      @mode&.operation == "deleted"
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
      @mode&.operation == "new"
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

    # @return [Boolean] True if this diff applies to a regular file.
    def normal_file?
      @mode&.bits == "100644"
    end

    # @return [Boolean] True if this diff applies to an executable.
    def executable?
      @mode&.bits == "100755"
    end

    # @return [Boolean] True if this diff applies to a symlink.
    def symlink?
      @mode&.bits == "120000"
    end

    # @return [String] The source of the symlink
    # @raise If this diff doesn't apply to a symlink
    def symlink_source
      raise(Error, "This diff doen't apply to a symbolic link") unless symlink?

      lines.first.content
    end

    # A utility method that returns the current number of a line who might not be present in the diff.
    # This is useful if you need to keep track of the updated line numbers in a file for every changes.
    #
    # @param line_number [Integer]
    #
    # @return [Integer]
    def previous_line_number_is_now(line_number)
      return line_number if line_unchanged?(line_number)

      applicable_hunk = last_applicable_hunk_for_line(line_number)
      line = applicable_hunk.find_previous_line(line_number)

      if line
        line.current_number
      else
        line_number + last_line_offset(applicable_hunk)
      end
    end

    # A naive implementation of `$ git apply`.
    #
    # @param previous_content [String] The previous content related to this diff.
    # @return [String] The content after applying this diff to the `previous_content`.
    def apply(previous_content)
      lines = previous_content.lines
      offset = 0

      self.lines.each do |line|
        if line.addition?
          lines.insert(line.current_number - 1, line.content)
          offset += 1
        elsif line.deletion?
          lines.delete_at(line.previous_number - 1 + offset)
          offset -= 1
        end
      end

      lines.join
    end

    # A naive implementation of `$ git apply -R`.
    #
    # @param current_content [String] The current content related to this diff.
    # @return [String] The content after reverting this diff to the `current_content`.
    def revert(current_content)
      lines = current_content.lines
      offset = 0

      self.lines.each do |line|
        if line.addition?
          lines.delete_at(line.current_number - 1 + offset)
          offset -= 1
        elsif line.deletion?
          lines.insert(line.previous_number - 1, line.content)
          offset += 1
        end
      end

      lines.join
    end

    private

    # @param line_number [Integer]
    #
    # @return [Boolean]
    def line_unchanged?(line_number)
      first_hunk = hunks.first

      line_number < first_hunk.new_file_start_line
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
