# frozen_string_literal: true

require "test_helper"

class GithubPatchParserTest < Minitest::Test
  def test_line_added
    parsed_patches = GithubDiffParser.parse_patch(read_patch("line_added"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("21e02a7fd129a0c17e3dfbf39c6e69240c3dc3d2", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:22:33 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 6, current_number: 6, patch_position: 1, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 2, type: :contextual? },
      { previous_number: 8, current_number: 8, patch_position: 3, type: :contextual? },
      { previous_number: nil, current_number: 9, patch_position: 4, type: :addition? },
      { previous_number: 9, current_number: 10, patch_position: 5, type: :contextual? },
      { previous_number: 10, current_number: 11, patch_position: 6, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_line_removed
    parsed_patches = GithubDiffParser.parse_patch(read_patch("line_removed"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("83f1c013cf33276439ee6577f5bf9c9307f294a7", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:23:10 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 6, current_number: 6, patch_position: 1, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 2, type: :contextual? },
      { previous_number: 8, current_number: 8, patch_position: 3, type: :contextual? },
      { previous_number: 9, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 10, current_number: 9, patch_position: 5, type: :contextual? },
      { previous_number: 11, current_number: 10, patch_position: 6, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_line_changed
    parsed_patches = GithubDiffParser.parse_patch(read_patch("line_changed"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("52602dc07fd225dabcdb472cc6a50ccc422fd201", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:23:53 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 5, current_number: 5, patch_position: 1, type: :contextual? },
      { previous_number: 6, current_number: 6, patch_position: 2, type: :contextual? },
      { previous_number: 7, current_number: 7, patch_position: 3, type: :contextual? },
      { previous_number: 8, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: nil, current_number: 8, patch_position: 5, type: :addition? },
      { previous_number: 9, current_number: 9, patch_position: 6, type: :contextual? },
      { previous_number: 10, current_number: 10, patch_position: 7, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_added
    parsed_patches = GithubDiffParser.parse_patch(read_patch("file_added"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("79c3454d0de816ce0907a29da4de805730235f72", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:20:31 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("blabla.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :new_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(10, hunk.lines.count)
    assert_equal(10, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: nil, current_number: 1, patch_position: 1, type: :addition? },
      { previous_number: nil, current_number: 2, patch_position: 2, type: :addition? },
      { previous_number: nil, current_number: 3, patch_position: 3, type: :addition? },
      { previous_number: nil, current_number: 4, patch_position: 4, type: :addition? },
      { previous_number: nil, current_number: 5, patch_position: 5, type: :addition? },
      { previous_number: nil, current_number: 6, patch_position: 6, type: :addition? },
      { previous_number: nil, current_number: 7, patch_position: 7, type: :addition? },
      { previous_number: nil, current_number: 8, patch_position: 8, type: :addition? },
      { previous_number: nil, current_number: 9, patch_position: 9, type: :addition? },
      { previous_number: nil, current_number: 10, patch_position: 10, type: :addition? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_removed
    parsed_patches = GithubDiffParser.parse_patch(read_patch("file_removed"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("6a8a480afa4516dcfa56a0a2aa18a728e4049028", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:19:33 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("package.json", parsed_diff.previous_filename)
    assert_equal("package.json", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :deleted_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(11, hunk.lines.count)
    assert_equal(11, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 1, current_number: nil, patch_position: 1, type: :deletion? },
      { previous_number: 2, current_number: nil, patch_position: 2, type: :deletion? },
      { previous_number: 3, current_number: nil, patch_position: 3, type: :deletion? },
      { previous_number: 4, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 5, current_number: nil, patch_position: 5, type: :deletion? },
      { previous_number: 6, current_number: nil, patch_position: 6, type: :deletion? },
      { previous_number: 7, current_number: nil, patch_position: 7, type: :deletion? },
      { previous_number: 8, current_number: nil, patch_position: 8, type: :deletion? },
      { previous_number: 9, current_number: nil, patch_position: 9, type: :deletion? },
      { previous_number: 10, current_number: nil, patch_position: 10, type: :deletion? },
      { previous_number: 11, current_number: nil, patch_position: 11, type: :deletion? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_file_moved
    parsed_patches = GithubDiffParser.parse_patch(read_patch("file_moved"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("8d008dd5ce2851f960a797ee50750667e6eb58cc", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 15 Apr 2022 12:21:13 +0200"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(0, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :rename_mode?)
  end

  def test_rails_diff
    parsed_patches = GithubDiffParser.parse_patch(read_patch("rails"))
    assert_equal(1, parsed_patches.count)

    parsed_patch = parsed_patches[0]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("921263bb924210308aec9258a8fa445f147dd3b1", parsed_patch.commit)
    assert_equal(Time.parse("Wed, 12 Jan 2022 19:41:25 -0300"), parsed_patch.timestamp)

    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.previous_filename)
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.new_filename)
    assert_equal(2, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 23, current_number: 23, patch_position: 1, type: :contextual? },
      { previous_number: 24, current_number: 24, patch_position: 2, type: :contextual? },
      { previous_number: 25, current_number: 25, patch_position: 3, type: :contextual? },
      { previous_number: 26, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: 27, current_number: 26, patch_position: 5, type: :contextual? },
      { previous_number: 28, current_number: 27, patch_position: 6, type: :contextual? },
      { previous_number: 29, current_number: 28, patch_position: 7, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    hunk = parsed_diff.hunks[1]
    assert_equal(18, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(3, hunk.deletion_lines.count)
    assert_equal(9, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 46, current_number: 45, patch_position: 9, type: :contextual? },
      { previous_number: 47, current_number: 46, patch_position: 10, type: :contextual? },
      { previous_number: 48, current_number: 47, patch_position: 11, type: :contextual? },
      { previous_number: 49, current_number: nil, patch_position: 12, type: :deletion? },
      { previous_number: 50, current_number: nil, patch_position: 13, type: :deletion? },
      { previous_number: 51, current_number: nil, patch_position: 14, type: :deletion? },
      { previous_number: nil, current_number: 48, patch_position: 15, type: :addition? },
      { previous_number: nil, current_number: 49, patch_position: 16, type: :addition? },
      { previous_number: nil, current_number: 50, patch_position: 17, type: :addition? },
      { previous_number: nil, current_number: 51, patch_position: 18, type: :addition? },
      { previous_number: nil, current_number: 52, patch_position: 19, type: :addition? },
      { previous_number: nil, current_number: 53, patch_position: 20, type: :addition? },
      { previous_number: nil, current_number: 54, patch_position: 21, type: :addition? },
      { previous_number: nil, current_number: 55, patch_position: 22, type: :addition? },
      { previous_number: nil, current_number: 56, patch_position: 23, type: :addition? },
      { previous_number: 52, current_number: 57, patch_position: 24, type: :contextual? },
      { previous_number: 53, current_number: 58, patch_position: 25, type: :contextual? },
      { previous_number: 54, current_number: 59, patch_position: 26, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_multiple_patch
    parsed_patches = GithubDiffParser.parse_patch(read_patch("multiple"))
    assert_equal(2, parsed_patches.count)

    # Assert data on the first patch
    parsed_patch = parsed_patches[0]
    assert_equal(3, parsed_patch.diffs.count)
    assert_equal("3ab4a9d75b1ac0f574d59a7850dd96c8fdcebe48", parsed_patch.commit)
    assert_equal(Time.parse("Fri, 22 Apr 2022 23:22:45 +0000"), parsed_patch.timestamp)

    # Assert first diff on the first patch
    parsed_diff = parsed_patches[0].diffs.first
    assert_equal("railties/lib/rails/generators/app_base.rb", parsed_diff.previous_filename)
    assert_equal("railties/lib/rails/generators/app_base.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(9, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(3, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 24, current_number: 24, patch_position: 1, type: :contextual? },
      { previous_number: 25, current_number: 25, patch_position: 2, type: :contextual? },
      { previous_number: 26, current_number: 26, patch_position: 3, type: :contextual? },
      { previous_number: nil, current_number: 27, patch_position: 4, type: :addition? },
      { previous_number: nil, current_number: 28, patch_position: 5, type: :addition? },
      { previous_number: nil, current_number: 29, patch_position: 6, type: :addition? },
      { previous_number: 27, current_number: 30, patch_position: 7, type: :contextual? },
      { previous_number: 28, current_number: 31, patch_position: 8, type: :contextual? },
      { previous_number: 29, current_number: 32, patch_position: 9, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    # Assert second diff on the first patch
    parsed_diff = parsed_patches[0].diffs[1]
    assert_equal("railties/lib/rails/generators/app_name.rb", parsed_diff.previous_filename)
    assert_equal("railties/lib/rails/generators/app_name.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(8, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(1, hunk.addition_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 11, current_number: 11, patch_position: 1, type: :contextual? },
      { previous_number: 12, current_number: 12, patch_position: 2, type: :contextual? },
      { previous_number: 13, current_number: 13, patch_position: 3, type: :contextual? },
      { previous_number: 14, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: nil, current_number: 14, patch_position: 5, type: :addition? },
      { previous_number: 15, current_number: 15, patch_position: 6, type: :contextual? },
      { previous_number: 16, current_number: 16, patch_position: 7, type: :contextual? },
      { previous_number: 17, current_number: 17, patch_position: 8, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    # Assert third diff on the first patch
    parsed_diff = parsed_patches[0].diffs[2]
    assert_equal("railties/test/generators/app_generator_test.rb", parsed_diff.previous_filename)
    assert_equal("railties/test/generators/app_generator_test.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(11, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(5, hunk.addition_lines.count)

    expected_lines = [
      { previous_number: 989, current_number: 989, patch_position: 1, type: :contextual? },
      { previous_number: 990, current_number: 990, patch_position: 2, type: :contextual? },
      { previous_number: 991, current_number: 991, patch_position: 3, type: :contextual? },
      { previous_number: nil, current_number: 992, patch_position: 4, type: :addition? },
      { previous_number: nil, current_number: 993, patch_position: 5, type: :addition? },
      { previous_number: nil, current_number: 994, patch_position: 6, type: :addition? },
      { previous_number: nil, current_number: 995, patch_position: 7, type: :addition? },
      { previous_number: nil, current_number: 996, patch_position: 8, type: :addition? },
      { previous_number: 992, current_number: 997, patch_position: 9, type: :contextual? },
      { previous_number: 993, current_number: 998, patch_position: 10, type: :contextual? },
      { previous_number: 994, current_number: 999, patch_position: 11, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    # Assert data on the second patch
    parsed_patch = parsed_patches[1]
    assert_equal(1, parsed_patch.diffs.count)
    assert_equal("fe62bb5762edfc7ee4c3bc3048b77dcb5c4c8136", parsed_patches[1].commit)
    assert_equal(Time.parse("Thu, 28 Apr 2022 13:11:19 +0200"), parsed_patch.timestamp)

    # Assert first diff on the second patch
    parsed_diff = parsed_patch.diffs.first
    assert_equal("activerecord/lib/active_record/log_subscriber.rb", parsed_diff.previous_filename)
    assert_equal("activerecord/lib/active_record/log_subscriber.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(15, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(8, hunk.addition_lines.count)
    assert_equal(1, hunk.deletion_lines.count)

    expected_lines = [
      { previous_number: 51, current_number: 51, patch_position: 1, type: :contextual? },
      { previous_number: 52, current_number: 52, patch_position: 2, type: :contextual? },
      { previous_number: 53, current_number: 53, patch_position: 3, type: :contextual? },
      { previous_number: 54, current_number: nil, patch_position: 4, type: :deletion? },
      { previous_number: nil, current_number: 54, patch_position: 5, type: :addition? },
      { previous_number: nil, current_number: 55, patch_position: 6, type: :addition? },
      { previous_number: nil, current_number: 56, patch_position: 7, type: :addition? },
      { previous_number: nil, current_number: 57, patch_position: 8, type: :addition? },
      { previous_number: nil, current_number: 58, patch_position: 9, type: :addition? },
      { previous_number: nil, current_number: 59, patch_position: 10, type: :addition? },
      { previous_number: nil, current_number: 60, patch_position: 11, type: :addition? },
      { previous_number: nil, current_number: 61, patch_position: 12, type: :addition? },
      { previous_number: 55, current_number: 62, patch_position: 13, type: :contextual? },
      { previous_number: 56, current_number: 63, patch_position: 14, type: :contextual? },
      { previous_number: 57, current_number: 64, patch_position: 15, type: :contextual? },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  private

  def assert_equal(expected, *args)
    if expected.nil?
      assert_nil(*args)
    else
      super(expected, *args)
    end
  end

  def assert_line(expected, actual)
    assert_equal(
      expected[:previous_number],
      actual.previous_number,
      "The line previous number don't match. Expected: #{expected[:previous_number]}, Actual: #{actual.previous_number}"
    )

    assert_equal(
      expected[:current_number],
      actual.current_number,
      "The line actual number don't match. Expected: #{expected[:current_number]}, Actual: #{actual.current_number}"
    )

    assert_equal(
      expected[:patch_position],
      actual.patch_position,
      "The patch position don't match. Expected: #{expected[:patch_position]}, Actual: #{actual.patch_position}"
    )

    assert_predicate(actual, expected[:type])
  end
end
