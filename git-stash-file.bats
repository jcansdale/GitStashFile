#!/bin/bash

# Bash Automated Testing System
# https://github.com/sstephenson/bats

workspace="test_workspace"
branch_path="stash-file"

@test "default list stashed files" {
  file="file.txt"
  branch="${branch_path}/${file}"
  git branch $branch
  
  output=$(../git-stash-file)

  [[ $output == *$branch ]]
}

@test "stash file already in repo" {
  file="file.txt"
  branch="${branch_path}/${file}"
  original_content="original content"
  stash_content="stash content"
  printf "${original_content}" > $file
  git add $file
  git commit -m "add file"
  printf "${stash_content}" > $file
  
  ../git-stash-file $file -m message
  
  [[ $(<$file) == $original_content ]]
  git cherry-pick $branch
  [[ $(<$file) == $stash_content ]]
}

@test "stash file not in repo" {
  file="file.txt"
  branch="${branch_path}/${file}"
  stash_content="stash content"
  printf "${stash_content}" > $file
  
  ../git-stash-file $file -m message
  
  git status
  [[ ! -f $file ]]
  git cherry-pick $branch
  [[ $(<$file) == $stash_content ]]
}

@test "stash file branch exists" {
  file="file.txt"
  branch="${branch_path}/${file}"
  stash_content="stash content"
  printf "${stash_content}" > $file
  
  ../git-stash-file $file -m message
  
  run git rev-parse "$branch"
  [[ "$status" -eq 0 ]]
}

@test "exit with 2 when branch already exists" {
  file="file.txt"
  printf dummy > $file
  branch="${branch_path}/${file}"
  git branch "$branch"
  
  run ../git-stash-file $file -m message
  
  [[ "$status" -eq 2 ]]
}

@test "exit with 1 when file doesn't exist" {
  file="missing.txt"
  
  run ../git-stash-file $file -m message
  
  [[ "$status" -eq 1 ]]
}

setup() {
  mkdir $workspace
  cd $workspace
  git init
  printf "Hello, Git!" > README.md
  git add README.md
  git commit -m first
}

teardown() {
  cd ..
  rm -rf $workspace
}

