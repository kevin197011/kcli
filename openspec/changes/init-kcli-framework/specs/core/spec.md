# Spec: kcli Core Framework

## ADDED Requirements

### Requirement: CLI Entrypoint
The tool MUST provide a command-line interface named `kcli`.

#### Scenario: Running with no arguments
- Given the `kcli` tool is installed
- When I run `kcli`
- Then I should see a help message listing available modules.

### Requirement: Module Loading
Modules MUST be dynamically discoverable and loadable from the `lib/kcli/modules` directory.

#### Scenario: Adding a new module
- Given a file exists at `lib/kcli/modules/test.rb` defining a `Test` module
- When I run `kcli help`
- Then `test` should appear in the list of commands.

### Requirement: Ruby-based Configuration
The framework MUST support loading configuration from Ruby files.

#### Scenario: Loading a module config
- Given a config file `~/.kcli/test.rb` exists with setting `config.api_key = "123"`
- When the `test` module executes
- Then it should have access to the `api_key` value.
