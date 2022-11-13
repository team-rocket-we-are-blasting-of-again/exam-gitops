#!/usr/bin/env bash

curr_dir=$(pwd)
script=$1

echo "Running $script.sh in $curr_dir"
sh "scripts/$script.sh"

for root_dir in \
  $curr_dir/modules
#  $curr_dir/environments
do
  dirs_to_validate=$(find "$root_dir" -mindepth 1 -maxdepth 1 -type d)
  for dir_to_validate in $dirs_to_validate; do
    echo "Running $script.sh in $dirs_to_validate"
    sh "scripts/$script.sh"
  done
done