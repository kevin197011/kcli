# frozen_string_literal: true

# Copyright (c) 2025 kk
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

require 'time'

task default: %w[push]

# Generate a smart commit message
def generate_commit_message
  # Get staged changes
  diff_output = `git diff --cached --name-status 2>&1`
  return nil if diff_output.empty? || !$?.success?

  changed_files = diff_output.split("\n")
  return nil if changed_files.empty?

  # Analyze change types
  types = []
  scopes = []
  file_descriptions = []

  changed_files.each do |line|
    status, file = line.split("\t", 2)
    next unless file

    type, scope, description = analyze_file_change(status, file)
    types << type if type
    scopes << scope if scope
    file_descriptions << description if description
  end

  # Determine primary commit type (priority: feat > fix > docs > refactor > style > perf > test > chore)
  type_priority = {
    'feat' => 1,
    'fix' => 2,
    'docs' => 3,
    'refactor' => 4,
    'style' => 5,
    'perf' => 6,
    'test' => 7,
    'chore' => 8
  }

  main_type = types.min_by { |t| type_priority[t] || 9 } || 'chore'
  main_scope = scopes.compact.uniq.first || 'general'

  # Generate subject
  subject = generate_subject(main_type, main_scope, file_descriptions)

  # Generate body (only when multiple files changed)
  body = generate_body(changed_files) if changed_files.length > 1

  # Compose commit message
  message = "#{main_type}(#{main_scope}): #{subject}"
  message += "\n\n#{body}" if body

  message
end

# Analyze a single file change
def analyze_file_change(status, file)
  type = nil
  scope = nil
  description = nil

  # Determine type based on path and status
  case file
  when %r{^rules/}
    type = 'docs'
    scope = 'rules'
    description = "Update rules: #{File.basename(file)}"
  when %r{^backend/}
    type = status == 'A' ? 'feat' : 'refactor'
    scope = 'backend'
    description = "#{status == 'A' ? 'Add' : 'Update'} backend code: #{File.basename(file)}"
  when %r{^frontend/}
    type = status == 'A' ? 'feat' : 'refactor'
    scope = 'frontend'
    description = "#{status == 'A' ? 'Add' : 'Update'} frontend code: #{File.basename(file)}"
  when /\.(rb|rake)$/
    type = 'chore'
    scope = 'scripts'
    description = "Update scripts: #{File.basename(file)}"
  when /\.(sh|bash)$/
    type = 'chore'
    scope = 'scripts'
    description = "Update scripts: #{File.basename(file)}"
  when /\.(md|mdx|txt)$/
    type = 'docs'
    scope = 'docs'
    description = "Update docs: #{File.basename(file)}"
  when /\.(yml|yaml)$/
    type = 'ci'
    scope = 'ci'
    description = "Update CI config: #{File.basename(file)}"
  when /\.(json)$/
    type = 'chore'
    scope = 'config'
    description = "Update config: #{File.basename(file)}"
  when /\.(go)$/
    type = status == 'A' ? 'feat' : (status == 'D' ? 'refactor' : 'fix')
    scope = 'backend'
    description = "#{status == 'A' ? 'Add' : status == 'D' ? 'Delete' : 'Update'} Go file: #{File.basename(file)}"
  when /\.(ts|tsx|js|jsx)$/
    type = status == 'A' ? 'feat' : (status == 'D' ? 'refactor' : 'fix')
    scope = 'frontend'
    description = "#{status == 'A' ? 'Add' : status == 'D' ? 'Delete' : 'Update'} frontend file: #{File.basename(file)}"
  else
    type = 'chore'
    scope = 'general'
    description = "#{status == 'A' ? 'Add' : status == 'D' ? 'Delete' : 'Update'} file: #{File.basename(file)}"
  end

  # Adjust type based on status
  case status
  when 'D'
    type = 'refactor' if type == 'feat'
  when 'M'
    # Try to detect a fix (by keywords)
    if file.match?(/fix|bug|error|issue/i)
      type = 'fix'
    end
  end

  [type, scope, description]
end

# Generate subject
def generate_subject(type, scope, descriptions)
  return 'update project files' if descriptions.empty?

  # If only one file, use a more specific subject
  if descriptions.length == 1
    desc = descriptions.first
    # Extract key info
    case desc
    when /Update rules/i
      'update development rules'
    when /Add.*backend/i
      'add backend feature'
    when /Update.*backend/i
      'update backend code'
    when /Add.*frontend/i
      'add frontend feature'
    when /Update.*frontend/i
      'update frontend code'
    when /Update scripts/i
      'update build scripts'
    when /Update docs/i
      'update documentation'
    else
      desc.split(':').last&.strip || 'update project files'
    end
  else
    # Multiple files: use a generic subject
    case type
    when 'feat'
      'add new feature'
    when 'fix'
      'fix issues'
    when 'docs'
      'update documentation'
    when 'refactor'
      'refactor code'
    when 'style'
      'style cleanup'
    when 'perf'
      'performance improvements'
    when 'test'
      'update tests'
    when 'chore'
      'maintenance'
    else
      'update project files'
    end
  end
end

# Generate body
def generate_body(changed_files)
  lines = ['Changed files:']
  changed_files.each do |line|
    status, file = line.split("\t", 2)
    next unless file

    status_icon = case status
                  when 'A' then '✨'
                  when 'D' then '🗑️'
                  when 'M' then '📝'
                  when 'R' then '🔄'
                  else '📄'
                  end

    lines << "  #{status_icon} #{file}"
  end
  lines.join("\n")
end

task :push do
  # Check for changes
  status_output = `git status --porcelain 2>&1`
  if status_output.empty? || !$?.success?
    puts 'No changes to commit'
    exit 0
  end

  # Stage all changes
  system 'git add .'

  # Generate a smart commit message
  commit_message = generate_commit_message || "chore: update project files\n\n#{Time.now}"

  # Write commit message to a temp file
  require 'tempfile'
  temp_file = Tempfile.new('commit_message')
  temp_file.write(commit_message)
  temp_file.close

  # Commit using the temp file
  success = system("git commit -F #{temp_file.path}")

  temp_file.unlink

  unless success
    puts 'Commit failed'
    exit 1
  end

  puts "✅ Commit created: #{commit_message.lines.first.chomp}"

  # Pull latest changes
  pull_output = `git pull 2>&1`
  unless $?.success?
    if pull_output.include?('conflict') || pull_output.include?('CONFLICT')
      puts '❌ Merge conflict detected. Please resolve it and retry.'
      puts pull_output
      exit 1
    else
      puts '⚠️  git pull failed, continuing to push'
      puts pull_output if pull_output.length > 0
    end
  end

  # Push to remote
  push_output = `git push origin main 2>&1`
  unless $?.success?
    puts '❌ Push failed'
    puts push_output
    exit 1
  end

  puts '✅ Push succeeded'
end

task :run do
  system 'docker compose down -v'
  system 'docker compose up -d --build --remove-orphans'
  system 'docker compose logs -f'
end

# task :push do
#   system 'git add .'
#   system "git commit -m 'Update #{Time.now}'"
#   system 'git pull'
#   system 'git push origin main'
# end