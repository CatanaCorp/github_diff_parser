# frozen_string_literal: true

module GithubDiffParser
  # This class represents one patch section from a git format-patch output.
  # Each +Github:DiffParser+ object own one or more GithubDiffParser::Diff
  # objects.
  #
  # @example Parsing this patch returns 2 GithubDiffParser::Patch object
  #
  #   From 52602dc07fd225dabcdb472cc6a50ccc422fd201 Mon Sep 17 00:00:00 2001
  #   From: Edouard CHIN <chin.edouard@gmail.com>
  #   Date: Fri, 15 Apr 2022 12:23:53 +0200
  #   Subject: [PATCH 1/2] Line changed
  #
  #   ---
  #    app/my_file.rb | 2 +-
  #    1 file changed, 1 insertion(+), 1 deletion(-)
  #
  #   diff --git a/app/my_file.rb b/app/my_file.rb
  #   index d3dfbe4..ac0e8b3 100644
  #   --- a/app/my_file.rb
  #   +++ b/app/my_file.rb
  #   @@ -5,6 +5,6 @@ def test1
  #      end
  #
  #      def test2
  #   -    "This file is just added"
  #   +    "This line is changed"
  #      end
  #    end
  #
  #   From 8d008dd5ce2851f960a797ee50750667e6eb58cc Mon Sep 17 00:00:00 2001
  #   From: Edouard CHIN <chin.edouard@gmail.com>
  #   Date: Fri, 15 Apr 2022 12:21:13 +0200
  #   Subject: [PATCH 2/2] File moved
  #
  #   ---
  #    blabla.rb => app/my_file.rb | 0
  #    1 file changed, 0 insertions(+), 0 deletions(-)
  #    rename blabla.rb => app/my_file.rb (100%)
  #
  #   diff --git a/blabla.rb b/app/my_file.rb
  #   similarity index 100%
  #   rename from blabla.rb
  #   rename to app/my_file.rb
  class Patch
    # @return [String] (see #initialize)
    attr_reader :commit

    # @return [Array<GithubDiffParser::Diff>] all the diffs inside the patch section.
    attr_reader :diffs

    # @private
    attr_writer :diffs

    # @return [Time] the timestamp from the patch header
    attr_reader :timestamp

    # @private
    attr_writer :timestamp

    # @param commit [String] the commit SHA
    def initialize(commit)
      @commit = commit
    end
  end
end
