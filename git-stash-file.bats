#!/bin/bash

# https://github.com/sstephenson/bats

# how to pick
# git cherry-pick d42c389f

workspace="test_workspace"

@test "stash file already in repo" {
  file="file.txt"
  branch="stash-file/${file}"
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
  branch="stash-file/${file}"
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
  branch="stash-file/${file}"
  stash_content="stash content"
  printf "${stash_content}" > $file
  
  ../git-stash-file $file -m message
  
  run git rev-parse "$branch"
  [[ "$status" -eq 0 ]]
}

@test "exit with 2 when branch already exists" {
  file="file.txt"
  printf dummy > $file
  branch="stash-file/${file}"
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

