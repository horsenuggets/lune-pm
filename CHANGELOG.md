# Changelog

## 0.3.0
- Modernize CLI with Commandline Toolkit build and completion scripts
- Standardize CI workflows across all commandline-luau CLI repos
- Add per-repo Terraform config for branch protection
- Bump lune to 0.10.4-horse.14.2

## 0.2.2
- Restructured CLI to use root Command with Subcommands array pattern
- Extracted all 11 commands into individual modules under LpmCommand/
- Moved ProcessManager and ProcessStore to Helpers/ directory
- Added BuildExecutable.luau and GenerateVersion.luau scripts
- Added version embedding via __VERSION__.luau for compiled binaries
- Added Chalk dependency for colored build output
- Fixed submodule registration for luau-cicd and claude-md-luau
- Fixed config files to use correct project names
- Reverted CI to use lune run for submodule scripts

## 0.2.1
- Use kebab-case flag names (`--restart-delay`, `--max-restarts`, `--no-auto-restart`)
- Update commandline-luau to 0.0.7

## 0.2.0
- Added auto-restart on crash with configurable delay and max restarts
- Added `--restart-delay` flag for configuring restart wait time
- Added `--max-restarts` flag for limiting restart attempts
- Added `--no-auto-restart` flag to disable automatic restarts
- Added `--cwd` flag for setting working directory
- Added `--command` flag for running custom commands (not just Lune scripts)
- Added `startup` command for systemd boot persistence
- Added `monit` command for real-time process monitoring dashboard
- Added `--follow` / `-f` flag to `logs` command for live tailing
- Improved process status detection with actual PID checking
- Added environment variable support in process config

## 0.1.0
- Initial release
- Basic process management (start, stop, restart, list)
- Log viewing with tail
- Version management and rollback
