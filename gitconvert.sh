export GPG_KEY_ID=$(git config user.signingkey)

export CURRENT_DIR_FULL_PATH=$PWD

export CURRENT_DIR_NAME=${PWD##*/}

cd ../ 

export PARENT_FULL_PATH=$PWD

export NEW_DIR_FULL_PATH="$PARENT_FULL_PATH/$CURRENT_DIR_NAME-new"


if [ ! -d "$NEW_DIR_FULL_PATH" ]; then
  mkdir $NEW_DIR_FULL_PATH
  echo "Creating new directory for the converted branch at '$NEW_DIR_FULL_PATH'."
fi

if [ -d "$NEW_DIR_FULL_PATH" ]; then
  echo "Directory '$NEW_DIR_FULL_PATH' already exists."
fi

cd $NEW_DIR_FULL_PATH
echo "A"
echo "$NEW_DIR_FULL_PATH/.git"


if [ -d "$NEW_DIR_FULL_PATH/.git" ]; then
  echo "Git already initialized in '$NEW_DIR_FULL_PATH'. Do you want to reinitialize it?"
  read -p "WARNING: This deletes the directory '$NEW_DIR_FULL_PATH/.git', are you sure? ['I am sure'| N] " del_git_answer
  if [ "$del_git_answer" = "I am sure" ]; then
  echo "C"
  rm -rf .git
  echo "Deleting $NEW_DIR_FULL_PATH/.git.."
  fi
fi

echo Initializing git..
git init

cd $CURRENT_DIR_FULL_PATH

echo Rewriting commits..
git log --reverse --format="%H" | while read commit_hash; do
    author_email="$(git show -s --format=%ae $commit_hash)"
    author_name="$(git show -s --format=%an $commit_hash)"

    # Filter by author email
    #if [[ "$author_email" != "{YOUR EMAIL}" ]]; then
    #   continue
    #fi

    # Filter by author name
    if [[ "$author_name" != "{YOUR NAME}" ]]; then
        continue
    fi

    # Assigning the meta data values to commit
    export GIT_AUTHOR_DATE="$(git show -s --format='%aD' $commit_hash)"
    export GIT_COMMITTER_DATE="$(git show -s --format='%cD' $commit_hash)" 
    export GIT_AUTHOR_NAME="$(git show -s --format=%an $commit_hash)" 
    export GIT_AUTHOR_EMAIL="{YOUR EMAIL}" 
    export GIT_COMMITTER_NAME="$(git show -s --format=%cn $commit_hash)" 
    export GIT_COMMITTER_EMAIL="{YOUR EMAIL}" 
    
    git checkout $commit_hash -- . 

    git -C $NEW_DIR_FULL_PATH add -A
    git -C $NEW_DIR_FULL_PATH commit -S --gpg-sign="$GPG_KEY_ID" --allow-empty -m "$(git log -1 --format=%B $commit_hash)"
done


cd $NEW_DIR_FULL_PATH

read -p "Enter remote repo SSH url " ssh_url

git remote add origin $ssh_url

git branch -M main

git push -u origin main --force 

cd $CURRENT_DIR_NAME