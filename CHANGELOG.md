# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [1.2.0] - 2024-9-2
### Added
- Added `GithubDiffParser::Hunk#context` which returns the context of the hunk.
  In this example, it would return "def blabla"
  ```diff
  @@ +1,6 -1,18 def blabla
  ```

- Added `GithubDiffParser::Hunk#previous_line_count` which returns the prevous line count in a hunk.
  In this example, it would return 6.
  ```diff
  @@ +1,6 -1,18 def blabla
  ```

- Added `GithubDiffParser::Hunk#new_line_count` which returns the prevous line count in a hunk.
  In this example, it would return 18.
  ```diff
  @@ +1,6 -1,18 def blabla
  ```

### Fixed
- `GithubDiffParser::Diff#previous_line_number_is_now` could return a wrong value
  for the line number 1 in a file.

## [1.1.1] - 2024-2-21
### Fixed
- `GithubDiffParser::Diff#new_mode?` and ``GithubDiffParser::Diff#deleted_mode?` would raise
  an error with this kind of diff:

  ```diff
  diff --git a/blabla.rb b/app/my_file.rb
  similarity index 100%
  rename from blabla.rb
  rename to app/my_file.rb
  ```

## [1.1.0] - 2024-2-21
### Added
- Github Diff Parser parses the permissions bits and you now have have access to various method
  such as:
  - `GithubDiffParser::Diff#normal_file?` when the bits are 100644
  - `GithubDiffParser::Diff#executable?` when the bits are 107555
  - `GithubDiffParser::Diff#symlink?` when the bits are 120000
- Introduce `GithubDiffParser::Diff#symlink_source`. When the diff applies to a symbolic link, `symlink_source` will
  return the path to where the symbolic link points to.
- Introduce `GithubDiffParser::Diff#apply`, a simple implementation of `git apply`.
- Introduce `GithubDiffParser::Diff#revert`, a simple implementation of `git apply -R`.

### Fixed
- `GithubDiffParser::Line#content` didn't include `\n` (if the line had one).
