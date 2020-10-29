#!/usr/bin/env bash

om=$1 # 1st argument is om prefix
k=$2 # 2nd argument is k prefix
run=run_${om}${k%_} # run name
run_dir=$(pwd)/../runs/$run # full path to run directory

# Link shared input files to run directory
echo "Linking shared input"
shared_input=$(pwd)/../input/shared
for file in $(ls $shared_input); do
  ln -sf $shared_input/$file $run_dir/$file
done

# Link relevant generated input files to run directory
echo "Linking generated input"
generated_input=$(pwd)/../input/generated
prefixes=(${om} ${k})
for prefix in ${prefixes[@]}; do
  for file in $(ls $generated_input | grep $prefix); do
    ln -sf $generated_input/$file $run_dir/${file#$prefix} # link and trim prefix
  done
done

# Set up a build directory
if [[ $3 == --build ]]; then
  # Create mod subdirectory if it doesn't exist
  mod_dir=$(pwd)/../build/mods/${om}${k%_}
  [ ! -d $mod_dir ] && mkdir -p $mod_dir

  # Link shared code to mod subdirectory
  echo "Linking shared code"
  shared_code_dir=$(pwd)/../code/shared
  for file in $(ls $shared_code_dir); do
    ln -sf $shared_code_dir/$file $mod_dir/$file
  done

  echo "Linking generated code"
  generated_code_dir=$(pwd)/../code/generated
  prefixes=(${om}${k} ${k})
  for prefix in ${prefixes[@]}; do
    for file in $(ls $generated_code_dir | grep ^$prefix); do
      ln -sf $generated_code_dir/$file $mod_dir/${file#$prefix}
    done
  done
fi
