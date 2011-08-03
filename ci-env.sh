######
# This script configures rvm for different CI configurations.
#
# Use it by sourcing it:
#
#  . ci-env.sh
#
# This script assumes the gemset-create-on-use settings are set in your
# ~/.rvmrc:
#
#  rvm_install_on_use_flag=1
#  rvm_gemset_create_on_use_flag=1

GEMSET=castanet

echo ". ~/.rvm/scripts/rvm"
. ~/.rvm/scripts/rvm

unset RVM_RUBY
case "$ENV" in
'ci_1.8.7')
RVM_RUBY='ruby-1.8.7';
;;
'ci_1.9')
RVM_RUBY='ruby-1.9.2';
;;
'ci_jruby')
RVM_RUBY='jruby';
;;
'ci_rbx')
RVM_RUBY='rbx';
;;
esac

if [ -z "$RVM_RUBY" ]; then
    echo "Could not map env (ENV=\"${ENV}\") to an RVM version.";
    shopt -q login_shell
    if [ $? -eq 0 ]; then
        echo "This means you are still using the previously selected RVM ruby."
        echo "Probably not what you want -- aborting."
        # don't exit an interactive shell
        return;
    else
        exit 1;
    fi
fi

echo "Switching to ${RVM_RUBY}@${GEMSET}"
set +e
rvm use "${RVM_RUBY}@${GEMSET}"
if [ $? -ne 0 ]; then
    echo "Switch failed (are rvm_install_on_use_flag and rvm_gemset_create_on_use_flag set?)"
    exit 2;
fi
set -e

ruby -v

set +e
gem list -i rake
if [ $? -ne 0 ]; then
    echo "Installing rake since it is not available"
    gem install rake
fi
set -e
