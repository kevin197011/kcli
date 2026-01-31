# Tasks: Initialize kcli Framework

## Phase 1: Core Framework
- [x] Initialize `Gemfile` with `thor` and other essentials. <!-- id: 0 -->
- [x] Create basic `Kcli::Core` and `Kcli::Module` base classes. <!-- id: 1 -->
- [x] Implement dynamic module loading from `lib/kcli/modules`. <!-- id: 2 -->
- [x] Implement config loader supporting `~/.kcli/*.rb`. <!-- id: 3 -->
- [x] Create `bin/kcli` executable. <!-- id: 4 -->

## Phase 2: GCP Module
- [x] Add `google-cloud-compute-v1` to `Gemfile`. <!-- id: 5 -->
- [x] Implement `Kcli::Modules::Gcp` module. <!-- id: 6 -->
- [x] Implement `compute:list` command within the GCP module. <!-- id: 7 -->
- [x] Add table formatting for output. <!-- id: 8 -->

## Phase 3: Validation
- [x] Create a sample `~/.kcli/gcp.rb` for testing. <!-- id: 9 -->
- [x] Verify `kcli gcp compute list` works with mock or real data. <!-- id: 10 -->
