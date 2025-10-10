
function checkout_all {
    git fetch
    
    for remotebranch in $(git branch -r | grep -v HEAD); do
        localbranch=${remotebranch#origin/}
        
        if git show-ref --verify --quiet refs/heads/$localbranch; then
            echo "Branch '$localbranch' already exists locally, skipping..."
        else
            git branch --track $localbranch $remotebranch
        fi
    done
}

