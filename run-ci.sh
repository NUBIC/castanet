#!/usr/bin/env bash

# Runs a CI build.  Assumes:
#
# 1)	RVM is installed globally or in the build user's home directory.
# 2)	rvm_install_on_use_flag and rvm_create_on_use_flag are set.
# 3)	The Ruby environment to use is provided as the first argument.
# 4)	The gemset to use is provided as the second argument.

RAKE_VERSION='>= 0'
BUNDLER_VERSION='~> 1.0'

if [ -z $1 ]; then
	echo "Ruby environment not given; aborting"
	exit 1
fi

if [ -z $2 ]; then
	echo "Gemset not given; aborting"
	exit 1
fi

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  source "/usr/local/rvm/scripts/rvm"
else
  echo "An RVM installation was not found"
  exit 1
fi

set +e

rvm use $1@$2

gem list -i rake -v "$RAKE_VERSION"

if [ $? -ne 0 ]; then
	gem install rake -v "$RAKE_VERSION" --no-rdoc --no-ri
fi

gem list -i bundler -v "$BUNDLER_VERSION"

if [ $? -ne 0 ]; then
	gem install bundler -v "$BUNDLER_VERSION" --no-rdoc --no-ri
fi

set -e

bundle update
bundle exec rake udaeta:install_dependencies ci --trace
