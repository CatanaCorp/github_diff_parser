# frozen_string_literal: true

require_relative "lib/github_diff_parser/version"

Gem::Specification.new do |spec|
  spec.name = "github_diff_parser"
  spec.version = GithubDiffParser::VERSION
  spec.authors = ["Edouard CHIN"]
  spec.email = ["chin.edouard@gmail.com"]

  spec.summary = "A Ruby Gem to parse unified git diff output."
  spec.description = "A Ruby Gem to parse unified git diff output."

  spec.homepage = "https://github.com/Edouard-chin/git_diff_parser"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Edouard-chin/git_diff_parser"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency("byebug")
  spec.add_development_dependency("rubocop-shopify")
end
