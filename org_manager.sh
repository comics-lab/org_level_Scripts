#!/bin/bash

# Organization Manager Script
# Provides unified interface for GitHub organization repository management

set -euo pipefail

# Configuration
PROJECT_ROOT="/home/rmleonard/projects/Home Projects"
DEFAULT_CLONE_DIR="./"
CONFIG_FILE="${HOME}/.config/my_git.conf"
REPOS=()

# Load custom configuration if exists
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # source "$CONFIG_FILE"
        echo "not using config file"
    fi
}

# Error handling
handle_error() {
    local exit_code=$1
    local error_msg=$2
    echo "Error: $error_msg" >&2
    exit "$exit_code"
}

# Repository listing
get_repo_list() {
    local org_name="$1"
    if ! command -v gh >/dev/null 2>&1; then
        handle_error 2 "GitHub CLI 'gh' not found in PATH"
    fi

    if ! mapfile -t REPOS < <(gh repo list "$org_name" --limit 999 --json name --jq '.[].name'); then
        handle_error 3 "Failed to list repositories for organization: $org_name"
    fi
}

# Directory operations
ensure_org_dir() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    mkdir -p "$target_dir"
    echo "$target_dir"
}

# Individual repository operations
clone_single_repo() {
    local org_name="$1"
    local repo_name="$2"
    local target_dir="$3"
    
    if [[ -d "$target_dir/$repo_name" ]]; then
        echo "Repository $repo_name already exists, skipping..."
        return 0
    fi
    
    echo "Cloning $repo_name..."
    git clone "https://github.com/$org_name/$repo_name.git" "$target_dir/$repo_name"
}

pull_single_repo() {
    local repo_name="$1"
    local base_dir="$2"
    
    if ! pushd "$base_dir/$repo_name" >/dev/null 2>&1; then
        echo "Warning: Cannot access $repo_name, skipping..."
        return 0
    fi

    echo "Pulling $repo_name..."
    if ! git pull; then
        echo "Warning: git pull failed for $repo_name (continuing)"
    fi
    popd >/dev/null 2>&1
}

push_single_repo() {
    local repo_name="$1"
    local base_dir="$2"
    
    if ! pushd "$base_dir/$repo_name" >/dev/null 2>&1; then
        echo "Warning: Cannot access $repo_name, skipping..."
        return 0
    fi

    echo "Checking $repo_name for changes..."
    git add .
    if ! git diff --cached --quiet; then
        echo "Changes found in $repo_name, committing..."
        if ! git commit -q -m "MASS UPDATE: $repo_name"; then
            echo "Warning: git commit failed for $repo_name (continuing)"
        else
            if ! git push -q; then
                echo "Warning: git push failed for $repo_name (continuing)"
            fi
        fi
    else
        echo "No changes in $repo_name, skipping..."
    fi
    popd >/dev/null 2>&1
}

show_repo_status() {
    local repo_name="$1"
    local base_dir="$2"
    
    if ! pushd "$base_dir/$repo_name" >/dev/null 2>&1; then
        echo "$repo_name: NOT FOUND"
        return 0
    fi
    
    local status
    status=$(git status --porcelain)
    if [[ -n "$status" ]]; then
        echo "$repo_name: MODIFIED"
    else
        echo "$repo_name: CLEAN"
    fi
    popd >/dev/null 2>&1
}

# Command implementations
cmd_clone() {
    local org_name="$1"
    local target_dir
    target_dir=$(ensure_org_dir "$org_name")
    
    get_repo_list "$org_name"
    echo "Cloning ${#REPOS[@]} repositories from $org_name..."
    
    for repo in "${REPOS[@]}"; do
        clone_single_repo "$org_name" "$repo" "$target_dir"
    done
}

cmd_pull() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    
    [[ -d "$target_dir" ]] || handle_error 1 "Organization directory not found. Run 'clone' first."
    
    get_repo_list "$org_name"
    echo "Pulling updates for ${#REPOS[@]} repositories..."
    
    for repo in "${REPOS[@]}"; do
        pull_single_repo "$repo" "$target_dir"
    done
}

cmd_push() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    
    [[ -d "$target_dir" ]] || handle_error 1 "Organization directory not found. Run 'clone' first."
    
    get_repo_list "$org_name"
    echo "Checking ${#REPOS[@]} repositories for changes..."
    
    for repo in "${REPOS[@]}"; do
        push_single_repo "$repo" "$target_dir"
    done
}

cmd_status() {
    local org_name="$1"
    local target_dir="${PROJECT_ROOT}/${org_name}"
    
    [[ -d "$target_dir" ]] || handle_error 1 "Organization directory not found. Run 'clone' first."
    
    get_repo_list "$org_name"
    echo "Status for ${#REPOS[@]} repositories in $org_name:"
    echo "-------------------------------------------"
    
    for repo in "${REPOS[@]}"; do
        show_repo_status "$repo" "$target_dir"
    done
}

show_help() {
    cat << EOF
Usage: $(basename "$0") <command> <organization-name>

Commands:
    clone   Clone all repositories from the organization
    pull    Update all repositories with latest changes
    push    Commit and push changes across all repositories
    status  Show status of all repositories
    help    Show this help message

Example:
    $(basename "$0") clone comics-lab
    $(basename "$0") pull comics-lab
    $(basename "$0") status comics-lab
    $(basename "$0") push comics-lab
EOF
}

# Main script execution
main() {
    [[ $# -lt 1 ]] && { show_help; exit 1; }
    
    local command="$1"
    shift
    
    [[ $# -lt 1 ]] && handle_error 1 "Organization name required"
    
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

main "$@"
