# Organization-Level Scripts

This directory contains scripts for managing GitHub organizations and their repositories. It includes both individual scripts for specific operations and a combined management tool.

## Quick Start

### Combined Script (Recommended)
```bash
# Clone all repositories in an organization
./org_manager.sh clone comics-lab

# Pull latest changes across all repositories
./org_manager.sh pull comics-lab

# Push changes in all repositories
./org_manager.sh push comics-lab

# Show status of all repositories
./org_manager.sh status comics-lab
```

### Individual Scripts (Legacy)
```bash
./grab_org.sh comics-lab     # Clone repositories
./git_pull.sh comics-lab     # Pull latest changes
./git_push.sh comics-lab     # Push changes
```

## Detailed Documentation

### org_manager.sh

The main script that provides a unified interface for all organization-level operations.

#### Commands
- `clone`: Clone all repositories from an organization
- `pull`: Update all repositories with latest changes
- `push`: Commit and push changes across all repositories
- `status`: Show the status of all repositories
- `help`: Show help message

#### Examples

1. Initial setup of an organization:
```bash
./org_manager.sh clone comics-lab
```

2. Daily update workflow:
```bash
# Pull changes, make modifications, push back
./org_manager.sh pull comics-lab
# ... make changes ...
./org_manager.sh push comics-lab
```

3. Check status before operations:
```bash
./org_manager.sh status comics-lab
```

4. Complete workflow example:
```bash
./org_manager.sh clone comics-lab && \
./org_manager.sh pull comics-lab && \
# ... make changes ...
./org_manager.sh push comics-lab
```

#### Features
- Unified command interface
- Consistent error handling
- Skips empty commits
- Handles missing directories gracefully
- Compatible with existing script arguments

### Implementation Notes

- Uses `mapfile` for efficient repository list processing
- Automatically handles GitHub API pagination
- Preserves existing directory structure
- Compatible with credential helpers and SSH keys

### Requirements

- GitHub CLI (`gh`) installed and authenticated
- Git configured with appropriate credentials
- Bash 4.0 or newer recommended

### Configuration

Default configuration can be overridden by creating `~/.config/org_manager.conf`:

```bash
PROJECT_ROOT="/custom/path/to/projects"
DEFAULT_CLONE_DIR="./custom-dir"
```

## Legacy Scripts

The original individual scripts are maintained for compatibility and specific use cases. See [ORIGINAL_README.md](ORIGINAL_README.md) for their documentation.

## Troubleshooting

### Common Issues

1. **Script hangs during git operations**
   - Ensure SSH keys or credential helpers are configured
   - Check GitHub API rate limits
   - Verify network connectivity

2. **Permission denied**
   - Verify GitHub authentication
   - Check repository access permissions
   - Ensure SSH keys are properly configured

3. **Directory not found**
   - Run clone command first
   - Check PROJECT_ROOT setting
   - Verify organization name

### Getting Help

1. Use the help command:
```bash
./org_manager.sh help
```

2. Check the design documentation:
```bash
less DESIGN.md
```

## Contributing

See [DESIGN.md](DESIGN.md) for implementation details and future enhancements.

## License

MIT License - See LICENSE file for details