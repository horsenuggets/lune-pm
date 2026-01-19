# lune-pm

A process manager for Lune applications, similar to pm2.

## Features

- Start, stop, restart, and list processes
- Process logs with tail functionality
- Auto-restart on crash
- Version management and rollback
- Status monitoring

## Installation

```bash
rokit add horsenuggets/lune-pm
```

## Usage

```bash
# Start an application
lpm start ./app.luau --name myapp

# List running processes
lpm list

# View logs
lpm logs myapp

# Stop a process
lpm stop myapp

# Restart a process
lpm restart myapp

# Stop all processes
lpm stop all

# Delete a process from list
lpm delete myapp

# Deploy a new version
lpm deploy myapp ./new-version.luau

# Rollback to previous version
lpm rollback myapp
```
