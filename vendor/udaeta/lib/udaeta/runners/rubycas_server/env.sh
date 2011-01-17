#!/usr/bin/env bash

export rvm_project_rvmrc=0
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
  cd `dirname $0` && $*
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
  cd `dirname $0` && $*
else
  printf "No RVM installation found\n"
fi
