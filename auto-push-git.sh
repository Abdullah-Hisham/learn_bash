#!/bin/bash
BASE_DIR="$HOME/learn_bash"
LOG_FILE="$HOME/git_autoupload.log"

echo "========== Auto-push started: $(date) ==========" >> "$LOG_FILE"

while IFS= read -r -d '' gitdir; do
    proj_path=$(dirname "$gitdir")
    repo_name=$(basename "$proj_path")
    
    echo "[$(date)] Checking: $repo_name" >> "$LOG_FILE"
    
    if ! cd "$proj_path" 2>/dev/null; then
        echo "ERROR: Cannot enter $proj_path" >> "$LOG_FILE"
        continue
    fi
    
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "ERROR: Not a git repo: $repo_name" >> "$LOG_FILE"
        continue
    fi
    
    if ! git remote get-url origin >/dev/null 2>&1; then
        echo "SKIP: No remote for $repo_name" >> "$LOG_FILE"
        continue
    fi
    
    if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
        git add -A
        git commit -m "Auto-update: $(date +'%Y-%m-%d %H:%M')" >> "$LOG_FILE" 2>&1
        branch_name=$(git rev-parse --abbrev-ref HEAD)
        
        if git push origin "$branch_name" >> "$LOG_FILE" 2>&1; then
            echo "SUCCESS: Pushed $repo_name ($branch_name)" >> "$LOG_FILE"
        else
            echo "FAILED: Push failed for $repo_name" >> "$LOG_FILE"
        fi
    else
        echo "SKIP: No changes in $repo_name" >> "$LOG_FILE"
    fi
    
done < <(find "$BASE_DIR" -maxdepth 3 -name ".git" -type d -print0)

echo "========== Finished: $(date) ==========" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"