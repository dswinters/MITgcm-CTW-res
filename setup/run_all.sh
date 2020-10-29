#!/usr/bin/env bash

base_dir="$(pwd)/.."
run_dir="$base_dir/runs"
exec_dir="$base_dir/exec"

np_max=30          # Number of processes to run simultaneously
retry=30           # Seconds to wait before re-counting processes
sleep_between=30   # Seconds to let a run "spin up" before counting processes
                   # again. It that at least some small value is necessary here.
                   # With MPI it sometimes takes ~30 seconds for processes to
                   # spawn after calling mpirun.

readarray -t rnames < "${1}" # Get list of runs from input file
for rname in ${rnames[@]}; do
  id=${rname#run_}

  ex="$exec_dir/mitgcm_$id.ex"

  cd $run_dir/$rname           # enter simulations's directory
  np=$(pgrep 'mitgcm' | wc -l) # count number of mitgcm processes
  # Wait until we're running fewer than the maximum number of allowed processes
  while (( np >= np_max )); do
    echo "$np simulations running, retrying in $retry seconds"
    sleep $retry
    np=$(pgrep mitgcm | wc -l)
    done
  # Start simulation
  echo "$np simulations running, starting $rname"
  rm -f *.data *.meta *.nc STD*
  $ex &
  sleep $sleep_between
  done
