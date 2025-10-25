# Organization Manager Script Design

## Overview

`org_manager.sh` provides a unified interface for managing GitHub organization repositories while maintaining compatibility with existing individual scripts.

## Command Structure

```bash
./org_manager.sh <command> [options] <org-name>

Commands:
  clone   Clone all repositories from organization
  pull    Update all repositories with latest changes
  push    Commit and push changes across all repositories
  status  Show status of all repositories
  help    Show this help message
```

## Core Components

### 1. Configuration Management
```bash
# Shared configuration
PROJECT_ROOT="/home/rmleonard/projects/Home Projects"
DEFAULT_CLONE_DIR="./"
CONFIG_FILE="${HOME}/.config/org_manager.conf"

# Config loading
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}
```

### 2. Common Functions Library
```bash
# Repository listing with automatic method selection
get_repo_list() {
    local org_name="$1"
    # Future: Add repo count check for method selection
    mapfile -t REPOS < <(gh repo list "$org_name" --limit 999 --json name --jq '.[].name')
}

# Directory operations
ensure_org_dir() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    mkdir -p "$target_dir"
    echo "$target_dir"
}

# Error handling
handle_error() {
    local exit_code=$1
    local error_msg=$2
    echo "Error: $error_msg" >&2
    exit "$exit_code"
}
```

### 3. Command Implementation

Each command is implemented as a function:

```bash
cmd_clone() {
    local org_name="$1"
    local target_dir
    target_dir=$(ensure_org_dir "$org_name")
    
    get_repo_list "$org_name"
    for repo in "${REPOS[@]}"; do
        clone_single_repo "$org_name" "$repo" "$target_dir"
    done
}

cmd_pull() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    
    [[ -d "$target_dir" ]] || handle_error 1 "Organization directory not found"
    
    get_repo_list "$org_name"
    for repo in "${REPOS[@]}"; do
        pull_single_repo "$repo" "$target_dir"
    done
}

cmd_push() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    
    [[ -d "$target_dir" ]] || handle_error 1 "Organization directory not found"
    
    get_repo_list "$org_name"
    for repo in "${REPOS[@]}"; do
        push_single_repo "$repo" "$target_dir"
    done
}
```

### 4. Helper Functions

```bash
clone_single_repo() {
    local org_name="$1"
    local repo_name="$2"
    local target_dir="$3"
    
    echo "Cloning $repo_name..."
    git clone "https://github.com/$org_name/$repo_name.git" "$target_dir/$repo_name"
}

pull_single_repo() {
    local repo_name="$1"
    local base_dir="$2"
    
    pushd "$base_dir/$repo_name" >/dev/null 2>&1 || return 1
    echo "Pulling $repo_name..."
    git pull
    popd >/dev/null 2>&1
}

push_single_repo() {
    local repo_name="$1"
    local base_dir="$2"
    
    pushd "$base_dir/$repo_name" >/dev/null 2>&1 || return 1
    echo "Checking $repo_name for changes..."
    git add .
    if ! git diff --cached --quiet; then
        git commit -q -m "MASS UPDATE: $repo_name"
        git push -q
    fi
    popd >/dev/null 2>&1
}
```

### 5. Main Script Flow

```bash
main() {
    local command="$1"
    shift
    
    load_config
    
    case "$command" in
        clone)  cmd_clone "$@" ;;
        pull)   cmd_pull "$@" ;;
        push)   cmd_push "$@" ;;
        status) cmd_status "$@" ;;
        help)   show_help ;;
        *)      handle_error 1 "Unknown command: $command" ;;
    esac
}
```

## Error Handling Strategy

1. Each function returns meaningful exit codes
2. Errors are logged to stderr
3. Critical errors terminate script
4. Non-critical errors (e.g., single repo failure) continue execution

## Future Enhancements

1. Repository count detection and method selection:
```bash
select_repo_method() {
    local org_name="$1"
    local count
    count=$(gh repo list "$org_name" --limit 1000 --json name | jq length)
    
    if (( count > 100 )); then
        use_tempfile_method
    else
        use_mapfile_method
    fi
}
```

2. Progress tracking and reporting
3. Parallel operations for large organizations
4. Dry-run mode
5. Configuration file support
6. Interactive mode

## Compatibility

The script maintains backward compatibility by:
1. Accepting same arguments as individual scripts
2. Preserving existing directory structure
3. Using similar commit messages and operation patterns

Would you like me to proceed with implementing this design?