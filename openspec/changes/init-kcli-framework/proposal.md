# Proposal: Initialize kcli Framework

## Problem
Operations teams need a flexible, modular CLI tool to automate various tasks across different cloud providers and services. Current tools often have rigid configuration formats (YAML/JSON) that lack the power of a full programming language for complex logic.

## Solution
Create `kcli`, a Ruby-based CLI framework that:
1. Supports modular plugins for different operational tasks.
2. Uses Ruby files for configuration, allowing for dynamic logic within the config.
3. Provides a unified interface for executing various toolsets.

### Key Features
- **Modular Architecture**: Modules (e.g., `gcp`, `aws`, `k8s`) are self-contained classes.
- **Ruby Config Loading**: Configurations are DSL-like Ruby files loaded at runtime.
- **Example Implementation**: A GCP module to list compute instances using the `google-cloud-compute` SDK.

## Scope
- Base CLI structure using `thor` or similar.
- Dynamic module loading mechanism.
- Config loading mechanism (supporting local and global Ruby configs).
- Implementation of the `gcp` module as a reference.
