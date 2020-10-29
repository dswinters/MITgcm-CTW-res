#!/usr/bin/env bash

base_dir="$(pwd)"
build_dir="$base_dir/../build"        # contains build folders for each theta
mod_dir="$base_dir/../build/mods"
exec_dir="$base_dir/../exec"          # to put executables when done
mitgcm_root="$HOME/MITgcm/MITgcm"     # MITgcm folder (from github)
buildopts="$HOME/MITgcm/build_options_shearwater" # build options file

# make directories
[ ! -d $exec_dir ] && mkdir $exec_dir
[ ! -d $build_dir ] && mkdir $build_dir

# enter build directory
cd $build_dir


shopt -s extglob
for mod in $(ls $mod_dir); do
  rm -f !(mods)
  $mitgcm_root/tools/genmake2 -mpi -enable=mnc -mods "$mod_dir/$mod" -optfile "$buildopts" --rootdir "$mitgcm_root"
  make -j 128 clean
  make -j 128 depend
  make -j 128
  mv mitgcmuv $exec_dir/mitgcm_$mod.ex
done
