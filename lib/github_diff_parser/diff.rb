    # @return [String] the hash of the previous file. This is indicate in the diff
    #   by the line `index abc..def`. The +abc+ part is the previous_index.
    attr_reader :previous_index

    # @return [String] the hash of the new file. This is indicate in the diff
    #   by the line `index abc..def`. The +def+ part is the previous_index.
    attr_reader :new_index

    attr_writer :file_mode, :previous_index, :new_index
    # Get all the lines in this diff. Shortcut for `diff.hunks.each { |h| h.lines }`
    def lines
      hunks.flat_map(&:lines)
    end

      patch_position = hunks.flat_map(&:lines).count + hunks.count