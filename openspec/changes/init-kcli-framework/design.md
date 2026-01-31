# Design: kcli Modular Architecture

## Overview
`kcli` is designed to be a lightweight orchestrator for operational scripts. It follows a "Convention over Configuration" approach but allows the "Configuration" to be executable Ruby code.

## Architecture

### 1. Core Loader
- **Executable**: `bin/kcli`
- Responsibility: Parse global options, locate modules, and delegate execution.
- Logic:
  - Look for modules in `lib/kcli/modules/*.rb`.
  - Look for configurations in `~/.kcli/config.rb` and `./.kcli/config.rb`.

### 2. Module Definition
Each module is a class inheriting from `Kcli::Module`.
- `name`: Human-readable name and CLI command name.
- `depends_on`: Gems required for the module (loaded only when needed).
- `execute`: Main entry point for the module logic.

### 3. Configuration System
Configs are Ruby files that define a block or a set of variables.
Example `~/.kcli/gcp.rb`:
```ruby
Kcli.configure(:gcp) do |config|
  config.project_id = "my-project-id"
  config.region = "us-central1"
end
```

### 4. GCP Module Example
- Uses `google-cloud-compute-v1` gem.
- Fetches instances from the configured project.
- Outputs a clean table of instances.

## Design Trade-offs
- **Ruby for Config**: 
  - *Pros*: Extremely flexible, easy to use environment variables, conditionals, or even fetch secrets dynamically.
  - *Cons*: Security risk if running untrusted configs (mitigated as this is a personal/internal tool).
- **Thor vs. Custom Parser**: `Thor` is standard for Ruby CLIs and handles subcommands gracefully.
