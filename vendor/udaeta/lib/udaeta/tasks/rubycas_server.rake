require 'bundler'

namespace :udaeta do
  task :check_dependencies => 'rubycas_server:check_dependencies'

  task :install_dependencies => 'rubycas_server:install_dependencies'

  namespace :rubycas_server do
    DESIRED_RUBY = '1.8.7'
    DESIRED_BUNDLER = '=1.0.7'
    DESIRED_GEMSET = 'castanet'
    RVM_SPEC = "#{DESIRED_RUBY}@#{DESIRED_GEMSET}"

    task :check_dependencies => [:check_rvm, :check_ruby, :check_gemset]

    task :install_dependencies => [:install_ruby, :create_gemset, :install_bundle]

    # ---

    task :check_rvm do
      `type rvm`

      if $?.to_i != 0
        fail %Q{
  RVM was not detected on your system.
  For installation and troubleshooting instructions, see http://rvm.beginrescueend.com.
        }
      else
        $stderr.puts 'RVM present.'
      end
    end
  
    task :check_ruby do
      unless desired_ruby_present?
        fail "An installation of Ruby #{DESIRED_RUBY} was not detected in your RVM install."
      else
        puts "Ruby #{DESIRED_RUBY} present."
      end
    end

    task :check_gemset do
      unless desired_gemset_present?
        fail "There is no "#{DESIRED_GEMSET}" gemset in your Ruby #{DESIRED_RUBY} environment."
      else
        puts "#{DESIRED_GEMSET} gemset present."
      end
    end

    task :install_ruby do
      sh "rvm install #{DESIRED_RUBY}" unless desired_ruby_present?
    end

    task :create_gemset do
     sh "rvm #{DESIRED_RUBY} gemset create #{DESIRED_GEMSET}" unless desired_gemset_present?
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
        sh "rvm #{RVM_SPEC} exec gem install bundler -v #{DESIRED_BUNDLER}"
      end
    end

    def desired_ruby_present?
      !`rvm list | grep #{DESIRED_RUBY} | tail -n1`.strip.empty?
    end
    
    def desired_gemset_present?
      !`rvm #{DESIRED_RUBY} gemset list | grep #{DESIRED_GEMSET}`.strip.empty?
    end

    def desired_bundler_present?
      `rvm #{RVM_SPEC} exec gem list -i bundler -v #{DESIRED_BUNDLER}`
      $? == 0
    end

    def gemfile
      File.expand_path(File.join(File.dirname(__FILE__), %w(.. runners rubycas_server Gemfile)))
    end
  end
end
