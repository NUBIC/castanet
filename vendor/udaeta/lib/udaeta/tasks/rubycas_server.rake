require 'bundler'

require File.expand_path('../load_udaeta', __FILE__)

require 'udaeta'

namespace :udaeta do
  task :check_dependencies => 'rubycas_server:check_dependencies'

  task :install_dependencies => 'rubycas_server:install_dependencies'

  namespace :rubycas_server do
    DESIRED_BUNDLER = '~> 1.0'
    RVM_SPEC = Udaeta::Controllers::RubycasServer.rvm_spec

    task :check_dependencies => [:check_rvm, :check_ruby_and_gemset]

    task :install_dependencies => [:install_ruby_and_gemset, :install_bundle]

    # ---

    task :check_rvm do
      system 'sh -c "type rvm"'

      if $?.to_i != 0
        fail %Q{
  RVM was not detected on your system.
  For installation and troubleshooting instructions, see http://rvm.beginrescueend.com.
        }
      else
        $stderr.puts 'RVM present.'
      end
    end
  
    task :check_ruby_and_gemset do
      unless ruby_and_gemset_present?
        fail "Could not activate RVM environment #{RVM_SPEC}."
      else
        puts "RVM environment #{RVM_SPEC} present."
      end
    end

    task :install_ruby_and_gemset do
      ENV['rvm_install_on_use_flag'] = '1'
      ENV['rvm_gemset_create_on_use_flag'] = '1'

      sh "rvm use #{RVM_SPEC}"
    end

    desc "Install the gem bundle for RubyCAS-Server to #{RVM_SPEC}"
    task :install_bundle => :install_bundler do
      Bundler.with_clean_env do
        cd File.dirname(gemfile) do
          sh "rvm #{RVM_SPEC} exec bundle install"
        end
      end
    end

    desc "Update the gem bundle for RubyCAS-Server in #{RVM_SPEC}"
    task :update_bundle => :install_bundler do
      Bundler.with_clean_env do
        cd File.dirname(gemfile) do
          sh "rvm #{RVM_SPEC} exec bundle update"
        end
      end
    end

    task :install_bundler do
      unless desired_bundler_present?
        sh "rvm #{RVM_SPEC} exec gem install bundler -v '#{DESIRED_BUNDLER}'"
      end
    end

    def ruby_and_gemset_present?
      system "sh -c 'rvm use #{RVM_SPEC}'"
      $? == 0
    end

    def desired_bundler_present?
      `rvm #{RVM_SPEC} exec gem list -i bundler -v '#{DESIRED_BUNDLER}'`
      $? == 0
    end

    def gemfile
      File.expand_path(File.join(File.dirname(__FILE__), %w(.. servers rubycas_server Gemfile)))
    end
  end
end
