# Spec: GCP Module for kcli

## ADDED Requirements

### Requirement: GCP Compute List
The `gcp` module MUST provide a command to list compute instances.

#### Scenario: Listing instances
- Given valid GCP credentials and configuration (project_id)
- When I run `kcli gcp compute list`
- Then I should see a table containing Instance Name, Status, and Zone.

### Requirement: GCP Configuration
The `gcp` module MUST use credentials and project settings from a Ruby config file.

#### Scenario: Missing configuration
- Given no GCP configuration file exists
- When I run `kcli gcp compute list`
- Then I should see an error message instructing me to create `~/.kcli/gcp.rb`.
