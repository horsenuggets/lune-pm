# Changelog

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
