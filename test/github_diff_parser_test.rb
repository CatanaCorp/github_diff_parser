# frozen_string_literal: true

require "test_helper"

class GithubDiffParserTest < Minitest::Test
  def test_line_added
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.addition_lines.count)
    assert_equal("def test1", hunk.context)
    assert_equal(5, hunk.previous_line_count)
    assert_equal(6, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 6,
        current_number: 6,
        patch_position: 1,
        type: :contextual?,
        content: "\n",
      },
      {
        previous_number: 7,
        current_number: 7,
        patch_position: 2,
        type: :contextual?,
        content: "  def test2\n",
      },
      {
        previous_number: 8,
        current_number: 8,
        patch_position: 3,
        type: :contextual?,
        content: "    \"This file is just added\"\n",
      },
      {
        previous_number: nil,
        current_number: 9,
        patch_position: 4,
        type: :addition?,
        content: "    \"This is a new line\"\n",
      },
      {
        previous_number: 9,
        current_number: 10,
        patch_position: 5,
        type: :contextual?,
        content: "  end\n",
      },
      {
        previous_number: 10,
        current_number: 11,
        patch_position: 6,
        type: :contextual?,
        content: "end\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_line_removed
    parsed_diffs = GithubDiffParser.parse(read_diff("line_removed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(6, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal("def test1", hunk.context)
    assert_equal(6, hunk.previous_line_count)
    assert_equal(5, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 6,
        current_number: 6,
        patch_position: 1,
        type: :contextual?,
        content: "\n",
      },
      {
        previous_number: 7,
        current_number: 7,
        patch_position: 2,
        type: :contextual?,
        content: "  def test2\n",
      },
      {
        previous_number: 8,
        current_number: 8,
        patch_position: 3,
        type: :contextual?,
        content: "    \"This file is just added\"\n",
      },
      {
        previous_number: 9,
        current_number: nil,
        patch_position: 4,
        type: :deletion?,
        content: "    \"This is a new line\"\n",
      },
      {
        previous_number: 10,
        current_number: 9,
        patch_position: 5,
        type: :contextual?,
        content: "  end\n",
      },
      {
        previous_number: 11,
        current_number: 10,
        patch_position: 6,
        type: :contextual?,
        content: "end\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_line_changed
    parsed_diffs = GithubDiffParser.parse(read_diff("line_changed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal(1, hunk.addition_lines.count)
    assert_equal("def test1", hunk.context)
    assert_equal(6, hunk.previous_line_count)
    assert_equal(6, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 5,
        current_number: 5,
        patch_position: 1,
        type: :contextual?,
        content: "  end\n",
      },
      {
        previous_number: 6,
        current_number: 6,
        patch_position: 2,
        type: :contextual?,
        content: "\n",
      },
      {
        previous_number: 7,
        current_number: 7,
        patch_position: 3,
        type: :contextual?,
        content: "  def test2\n",
      },
      {
        previous_number: 8,
        current_number: nil,
        patch_position: 4,
        type: :deletion?,
        content: "    \"This file is just added\"\n",
      },
      {
        previous_number: nil,
        current_number: 8,
        patch_position: 5,
        type: :addition?,
        content: "    \"This line is changed\"\n",
      },
      {
        previous_number: 9,
        current_number: 9,
        patch_position: 6,
        type: :contextual?,
        content: "  end\n",
      },
      {
        previous_number: 10,
        current_number: 10,
        patch_position: 7,
        type: :contextual?,
        content: "end\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_file_added
    parsed_diffs = GithubDiffParser.parse(read_diff("file_added"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("blabla.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :new_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(10, hunk.lines.count)
    assert_equal(10, hunk.addition_lines.count)
    assert_equal("", hunk.context)
    assert_equal(0, hunk.previous_line_count)
    assert_equal(10, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: nil,
        current_number: 1,
        patch_position: 1,
        type: :addition?,
        content: "# frozen_string_literal: true\n",
      },
      {
        previous_number: nil,
        current_number: 2,
        patch_position: 2,
        type: :addition?,
        content: "\n",
      },
      {
        previous_number: nil,
        current_number: 3,
        patch_position: 3,
        type: :addition?,
        content: "class FileAdded\n",
      },
      {
        previous_number: nil,
        current_number: 4,
        patch_position: 4,
        type: :addition?,
        content: "  def test1\n",
      },
      {
        previous_number: nil,
        current_number: 5,
        patch_position: 5,
        type: :addition?,
        content: "  end\n",
      },
      {
        previous_number: nil,
        current_number: 6,
        patch_position: 6,
        type: :addition?,
        content: "\n",
      },
      {
        previous_number: nil,
        current_number: 7,
        patch_position: 7,
        type: :addition?,
        content: "  def test2\n",
      },
      {
        previous_number: nil,
        current_number: 8,
        patch_position: 8,
        type: :addition?,
        content: "    \"This file is just added\"\n",
      },
      {
        previous_number: nil,
        current_number: 9,
        patch_position: 9,
        type: :addition?,
        content: "  end\n",
      },
      {
        previous_number: nil,
        current_number: 10,
        patch_position: 10,
        type: :addition?,
        content: "end\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_file_removed
    parsed_diffs = GithubDiffParser.parse(read_diff("file_removed"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("package.json", parsed_diff.previous_filename)
    assert_equal("package.json", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :deleted_mode?)

    hunk = parsed_diff.hunks.first
    assert_equal(11, hunk.lines.count)
    assert_equal(11, hunk.deletion_lines.count)
    assert_equal("", hunk.context)
    assert_equal(11, hunk.previous_line_count)
    assert_equal(0, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 1,
        current_number: nil,
        patch_position: 1,
        type: :deletion?,
        content: "{\n",
      },
      {
        previous_number: 2,
        current_number: nil,
        patch_position: 2,
        type: :deletion?,
        content: "  \"name\": \"canary\",\n",
      },
      {
        previous_number: 3,
        current_number: nil,
        patch_position: 3,
        type: :deletion?,
        content: "  \"private\": true,\n",
      },
      {
        previous_number: 4,
        current_number: nil,
        patch_position: 4,
        type: :deletion?,
        content: "  \"dependencies\": {\n",
      },
      {
        previous_number: 5,
        current_number: nil,
        patch_position: 5,
        type: :deletion?,
        content: "    \"@rails/ujs\": \"^6.0.0\",\n",
      },
      {
        previous_number: 6,
        current_number: nil,
        patch_position: 6,
        type: :deletion?,
        content: "    \"turbolinks\": \"^5.2.0\",\n",
      },
      {
        previous_number: 7,
        current_number: nil,
        patch_position: 7,
        type: :deletion?,
        content: "    \"@rails/activestorage\": \"^6.0.0\",\n",
      },
      {
        previous_number: 8,
        current_number: nil,
        patch_position: 8,
        type: :deletion?,
        content: "    \"@rails/actioncable\": \"^6.0.0\"\n",
      },
      {
        previous_number: 9,
        current_number: nil,
        patch_position: 9,
        type: :deletion?,
        content: "  },\n",
      },
      {
        previous_number: 10,
        current_number: nil,
        patch_position: 10,
        type: :deletion?,
        content: "  \"version\": \"0.1.0\"\n",
      },
      {
        previous_number: 11,
        current_number: nil,
        patch_position: 11,
        type: :deletion?,
        content: "}\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_file_moved
    parsed_diffs = GithubDiffParser.parse(read_diff("file_moved"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("blabla.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(0, parsed_diff.hunks.count)
    assert_predicate(parsed_diff, :rename_mode?)
    refute_predicate(parsed_diff, :new_mode?)
    refute_predicate(parsed_diff, :deleted_mode?)
    refute_predicate(parsed_diff, :normal_file?)
    refute_predicate(parsed_diff, :symlink?)
    refute_predicate(parsed_diff, :executable?)
  end

  def test_rails_diff
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.previous_filename)
    assert_equal("actionmailer/lib/action_mailer/railtie.rb", parsed_diff.new_filename)
    assert_equal(2, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal("class Railtie < Rails::Railtie # :nodoc:", hunk.context)
    assert_equal(7, hunk.previous_line_count)
    assert_equal(6, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 23,
        current_number: 23,
        patch_position: 1,
        type: :contextual?,
      },
      {
        previous_number: 24,
        current_number: 24,
        patch_position: 2,
        type: :contextual?,
      },
      {
        previous_number: 25,
        current_number: 25,
        patch_position: 3,
        type: :contextual?,
      },
      {
        previous_number: 26,
        current_number: nil,
        patch_position: 4,
        type: :deletion?,
      },
      {
        previous_number: 27,
        current_number: 26,
        patch_position: 5,
        type: :contextual?,
      },
      {
        previous_number: 28,
        current_number: 27,
        patch_position: 6,
        type: :contextual?,
      },
      {
        previous_number: 29,
        current_number: 28,
        patch_position: 7,
        type: :contextual?,
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)

    hunk = parsed_diff.hunks[1]
    assert_equal(18, hunk.lines.count)
    assert_equal(6, hunk.contextual_lines.count)
    assert_equal(3, hunk.deletion_lines.count)
    assert_equal(9, hunk.addition_lines.count)
    assert_equal("class Railtie < Rails::Railtie # :nodoc:", hunk.context)
    assert_equal(9, hunk.previous_line_count)
    assert_equal(15, hunk.new_line_count)

    expected_lines = [
      {
        previous_number: 46,
        current_number: 45,
        patch_position: 9,
        type: :contextual?,
      },
      {
        previous_number: 47,
        current_number: 46,
        patch_position: 10,
        type: :contextual?,
      },
      {
        previous_number: 48,
        current_number: 47,
        patch_position: 11,
        type: :contextual?,
      },
      {
        previous_number: 49,
        current_number: nil,
        patch_position: 12,
        type: :deletion?,
      },
      {
        previous_number: 50,
        current_number: nil,
        patch_position: 13,
        type: :deletion?,
      },
      {
        previous_number: 51,
        current_number: nil,
        patch_position: 14,
        type: :deletion?,
      },
      {
        previous_number: nil,
        current_number: 48,
        patch_position: 15,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 49,
        patch_position: 16,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 50,
        patch_position: 17,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 51,
        patch_position: 18,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 52,
        patch_position: 19,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 53,
        patch_position: 20,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 54,
        patch_position: 21,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 55,
        patch_position: 22,
        type: :addition?,
      },
      {
        previous_number: nil,
        current_number: 56,
        patch_position: 23,
        type: :addition?,
      },
      {
        previous_number: 52,
        current_number: 57,
        patch_position: 24,
        type: :contextual?,
      },
      {
        previous_number: 53,
        current_number: 58,
        patch_position: 25,
        type: :contextual?,
      },
      {
        previous_number: 54,
        current_number: 59,
        patch_position: 26,
        type: :contextual?,
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
    assert_predicate(parsed_diff, :normal_file?)
  end

  def test_when_range_header_has_no_comma
    parsed_diffs = GithubDiffParser.parse(read_diff("range_header_with_no_comma"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    assert_equal("app/my_file.rb", parsed_diff.previous_filename)
    assert_equal("app/my_file.rb", parsed_diff.new_filename)
    assert_equal(1, parsed_diff.hunks.count)

    hunk = parsed_diff.hunks.first
    assert_equal(7, hunk.lines.count)
    assert_equal(5, hunk.contextual_lines.count)
    assert_equal(1, hunk.deletion_lines.count)
    assert_equal(1, hunk.addition_lines.count)

    expected_lines = [
      {
        previous_number: 5,
        current_number: 5,
        patch_position: 1,
        type: :contextual?,
      },
      {
        previous_number: 6,
        current_number: 6,
        patch_position: 2,
        type: :contextual?,
      },
      {
        previous_number: 7,
        current_number: 7,
        patch_position: 3,
        type: :contextual?,
      },
      {
        previous_number: 8,
        current_number: nil,
        patch_position: 4,
        type: :deletion?,
      },
      {
        previous_number: nil,
        current_number: 8,
        patch_position: 5,
        type: :addition?,
      },
      {
        previous_number: 9,
        current_number: 9,
        patch_position: 6,
        type: :contextual?,
      },
      {
        previous_number: 10,
        current_number: 10,
        patch_position: 7,
        type: :contextual?,
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_content_when_file_has_no_newlines_on_a_new_file
    parsed_diffs = GithubDiffParser.parse(read_diff("no_newline"))

    assert_equal(3, parsed_diffs.count)

    hunk = parsed_diffs.first.hunks.first
    expected_lines = [
      {
        previous_number: nil,
        current_number: 1,
        patch_position: 1,
        type: :addition?,
        content: ".my-class {\n",
      },
      {
        previous_number: nil,
        current_number: 2,
        patch_position: 2,
        type: :addition?,
        content: "  color: red,\n",
      },
      {
        previous_number: nil,
        current_number: 3,
        patch_position: 3,
        type: :addition?,
        content: "}",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    hunk = parsed_diffs[1].hunks.first
    expected_lines = [
      {
        previous_number: 1,
        current_number: 1,
        patch_position: 1,
        type: :contextual?,
        content: ".my-class {\n",
      },
      {
        previous_number: 2,
        current_number: 2,
        patch_position: 2,
        type: :contextual?,
        content: "  color: red,\n",
      },
      {
        previous_number: 3,
        current_number: nil,
        patch_position: 3,
        type: :deletion?,
        content: "}\n",
      },
      {
        previous_number: nil,
        current_number: 3,
        patch_position: 4,
        type: :addition?,
        content: "}",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end

    hunk = parsed_diffs[2].hunks.first
    expected_lines = [
      {
        previous_number: 1,
        current_number: 1,
        patch_position: 1,
        type: :contextual?,
        content: ".my-class {\n",
      },
      {
        previous_number: 2,
        current_number: 2,
        patch_position: 2,
        type: :contextual?,
        content: "  color: red,\n",
      },
      {
        previous_number: 3,
        current_number: nil,
        patch_position: 3,
        type: :deletion?,
        content: "}",
      },
      {
        previous_number: nil,
        current_number: 3,
        patch_position: 4,
        type: :addition?,
        content: "}\n",
      },
    ]

    expected_lines.each_with_index do |expected_line, index|
      assert_line(expected_line, hunk.lines[index])
    end
  end

  def test_mode_bits
    parsed_diffs = GithubDiffParser.parse(read_diff("file_modes"))

    assert_equal(2, parsed_diffs.count)
    assert_predicate(parsed_diffs.first, :executable?)
    assert_raises(GithubDiffParser::Error) { parsed_diffs.first.symlink_source }

    assert_predicate(parsed_diffs[1], :symlink?)
    assert_equal("some_file.rb", parsed_diffs[1].symlink_source)
  end

  def test_raise_when_diff_is_not_a_diff
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("invalid"))
    end
  end

  def test_raise_when_diff_header_is_missing
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("diff_header_missing"))
    end
  end

  def test_raise_when_diff_hunk_range_is_missing
    assert_raises(GithubDiffParser::InvalidDiff) do
      GithubDiffParser.parse(read_diff("hunk_range_missing"))
    end
  end

  def test_lines
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))

    assert_equal(6, parsed_diffs[0].lines.count)
  end

  def test_index
    parsed_diffs = GithubDiffParser.parse(read_diff("line_added"))

    assert_equal("d3dfbe4", parsed_diffs[0].previous_index)
    assert_equal("03d99f2", parsed_diffs[0].new_index)
  end

  def test_revert
    parsed_diffs = GithubDiffParser.parse(read_diff("octokit"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    reverted_content = parsed_diff.revert(read_fixture("octokit_after.rb"))

    assert_equal(read_fixture("octokit_before.rb"), reverted_content)
  end

  def test_apply
    parsed_diffs = GithubDiffParser.parse(read_diff("octokit"))
    assert_equal(1, parsed_diffs.count)

    parsed_diff = parsed_diffs.first
    content = parsed_diff.apply(read_fixture("octokit_before.rb"))

    assert_equal(read_fixture("octokit_after.rb"), content)
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
      "The line previous number don't match. Expected: #{expected[:previous_number]}, " \
        "Actual: #{actual.previous_number}",
    )

    assert_equal(
      expected[:current_number],
      actual.current_number,
      "The line actual number don't match. Expected: #{expected[:current_number]}, Actual: #{actual.current_number}",
    )

    assert_equal(
      expected[:patch_position],
      actual.patch_position,
      "The patch position don't match. Expected: #{expected[:patch_position]}, Actual: #{actual.patch_position}",
    )

    if expected[:content]
      assert_equal(
        expected[:content],
        actual.content,
        "The content don't match. Expected: #{expected[:content]}, Actual: #{actual.content}",
      )
    end

    assert_predicate(actual, expected[:type])
  end
end
