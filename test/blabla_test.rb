# frozen_string_literal: true

require "test_helper"

class PreviousLineNumberIsNowTest < Minitest::Test
  def test_when_line_is_not_shifted_and_not_part_of_the_diff
    parsed_diffs = GithubDiffParser.parse(read_diff("example"))
    current_number = parsed_diffs.first.previous_line_number_is_now(44)

    assert_equal(44, current_number)
  end

  def test_when_line_is_not_shifted_and_is_the_first_of_the_hunk_range
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    current_number = parsed_diffs.first.previous_line_number_is_now(23)

    assert_equal(23, current_number)
  end

  def test_when_line_was_shifted_due_to_deleted_code
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    current_number = parsed_diffs.first.previous_line_number_is_now(28)

    assert_equal(27, current_number)
  end

  def test_when_line_was_shifted_due_to_deleted_code_but_is_not_part_of_the_diff
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    current_number = parsed_diffs.first.previous_line_number_is_now(45)

    assert_equal(44, current_number)
  end

  def test_when_line_was_deleted
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    current_number = parsed_diffs.first.previous_line_number_is_now(26)

    assert_nil(current_number)
  end

  def test_when_line_was_shifted_due_to_added_code
    parsed_diffs = GithubDiffParser.parse(read_diff("rails"))
    current_number = parsed_diffs.first.previous_line_number_is_now(54)

    assert_equal(59, current_number)
  end

  def test_multiple_hunks
    parsed_diffs = GithubDiffParser.parse(read_diff("example"))
    current_number = parsed_diffs.first.previous_line_number_is_now(65)

    assert_equal(65, current_number)

    current_number = parsed_diffs.first.previous_line_number_is_now(66)

    assert_equal(68, current_number)
  end
end
