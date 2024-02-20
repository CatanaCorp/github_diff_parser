    Mode = Struct.new(:operation, :bits)

    attr_writer :previous_index, :new_index

    # @private
    attr_accessor :mode
      @mode.operation == "deleted"
      @mode.operation == "new"
    # @return [Boolean] True if this diff applies to a regular file.
    def normal_file?
      @mode.bits == "100644"
    end

    # @return [Boolean] True if this diff applies to an executable.
    def executable?
      @mode.bits == "100755"
    end

    # @return [Boolean] True if this diff applies to a symlink.
    def symlink?
      @mode.bits == "120000"
    end

    # @return [String] The source of the symlink
    # @raise If this diff doesn't apply to a symlink
    def symlink_source
      raise(Error, "This diff doen't apply to a symbolic link") unless symlink?

      lines.first.content
    end
