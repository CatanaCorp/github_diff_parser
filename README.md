### GithubDiffParser

A Ruby Gem to parse the output of a Git Diff with an emphasises on actual line numbers **before** and **after** the changes apply. This gem matches the information you get when reviewing a Pull Request on GitHub in split mode.

## Usage

#### Given this diff

```diff
diff --git a/actionmailer/lib/action_mailer/railtie.rb b/actionmailer/lib/action_mailer/railtie.rb
index 70c4937c418b2..bd87fe1057f90 100644
--- a/actionmailer/lib/action_mailer/railtie.rb
+++ b/actionmailer/lib/action_mailer/railtie.rb
@@ -23,7 +23,6 @@ class Railtie < Rails::Railtie # :nodoc:
       options.stylesheets_dir ||= paths["public/stylesheets"].first
       options.show_previews = Rails.env.development? if options.show_previews.nil?
       options.cache_store ||= Rails.cache
-      options.smtp_settings ||= {}

       if options.show_previews
         options.preview_path ||= defined?(Rails.root) ? "#{Rails.root}/test/mailers/previews" : nil
@@ -46,9 +45,15 @@ class Railtie < Rails::Railtie # :nodoc:
           self.delivery_job = delivery_job.constantize
         end

-        if smtp_timeout = options.delete(:smtp_timeout)
-          options.smtp_settings[:open_timeout] ||= smtp_timeout
-          options.smtp_settings[:read_timeout] ||= smtp_timeout
+        if options.smtp_settings
+          self.smtp_settings = options.smtp_settings
+        end
+
+        smtp_timeout = options.delete(:smtp_timeout)
+
+        if self.smtp_settings && smtp_timeout
+          self.smtp_settings[:open_timeout] ||= smtp_timeout
+          self.smtp_settings[:read_timeout] ||= smtp_timeout
         end

         options.each { |k, v| send("#{k}=", v) }

```

```ruby
parsed_diffs = GithubDiffParser.parse(diff) # Returns an array of `GithubDiffParser:Diff` objects. Each object corresponding to a diff section in the Git Diff. In this example we only have one.

parsed_diffs.deleted_mode? # If this diff deleting a file. No in this example
parsed_diffs.new_mode? # If this diff adding a  new file. No in this example
parsed_diffs.rename_mode? # If this diff renaming or moving a file. No in this example

hunks = parsed_diffs.hunks # Returns an array of `GithubDiffParser::Hunk` objects. In this example we have two.
lines = parsed_diffs.hunks.first.lines # Returns an array of `GithubDiffParser::Line` objects. Each object represent a line that belongs to the hunk. A line in a git diff can be either a contextual, addition or a deletion line.

lines.first.previous_number # Return the line number before the changes. In this example it's 23
lines.first.current_number # Return the line number after the changes. In this example it's 23
lines.first.patch_position # Return the position of the line in this patch. In this example it's 1
lines.first.contextual?  # Returns true, the first line is a contextual line
```

See the API documentation for more example.
