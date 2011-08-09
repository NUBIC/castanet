#!/usr/bin/env bash -e

# Runs a CI build for castanet.  Assumes:
#
# 1)	RVM is installed in the build user's home directory and can be
# 	activated by sourcing ~/.rvm/scripts/rvm.
#
# 2)	rvm_install_on_use_flag and rvm_create_on_use_flag are set.
#
# 3)	The Ruby environment to use is provided as the first argument.

if [ -z $1 ]; then
	echo "Ruby environment not given; aborting"
	exit 1
fi

. ~/.rvm/scripts/rvm

set +e
rvm use $1@castanet

rake -f init.rakefile
bundle exec rake udaeta:install_dependencies --trace
bundle exec rake ci --trace
