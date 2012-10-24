require 'erb'
require 'yaml'

# This is a ridiculous amount of setup for a CAS server.

namespace :servers do
  namespace :jasig do
    JASIG_URL = 'http://downloads.jasig.org/cas/cas-server-3.5.0-release.tar.gz'
    JETTY_URL = 'http://download.eclipse.org/jetty/8.1.7.v20120910/dist/jetty-distribution-8.1.7.v20120910.tar.gz'

    JASIG_PORT = 51983

    JASIG_DIR = "#{DOWNLOAD_DIR}/jasig-cas"
    JETTY_DIR = "#{DOWNLOAD_DIR}/jetty"
    KEYSTORE = "#{JETTY_DIR}/jetty.ks"
    JETTY_SSL_CONFIG = "#{JETTY_DIR}/etc/jetty-cas-ssl.xml"
    
    STOREPASS = 'secret'

    desc 'Start the Jasig CAS server for integration tests'
    task :start do
      exec "cd #{JETTY_DIR} && exec java -jar start.jar"
    end

    desc 'Prep the Jasig CAS server for use in integration tests'
    task :prep => ['jasig:download', 'jasig:configure']

    task :endpoints do
      data = { :cas => "https://localhost:#{JASIG_PORT}/cas-server-uber-webapp-3.5.0/" }.to_yaml

      puts data
    end

    task :download do
      [[JASIG_URL, JASIG_DIR], [JETTY_URL, JETTY_DIR]].each do |url, dest_dir|
        dest_file = File.expand_path("#{DOWNLOAD_DIR}/#{url.split('/').last}")

        mkdir_p dest_dir

        sh "wget -q #{url} -O #{dest_file}" if !File.exists?(dest_file)
        sh "tar xf #{dest_file} -C #{dest_dir} --strip-components 1"
      end
    end

    task :configure => :configure_jetty do
      # Copy the uber-webapp WAR to Jetty's webapps directory.
      cp "#{JASIG_DIR}/modules/cas-server-uber-webapp-3.5.0.war", "#{JETTY_DIR}/webapps"

      # The Jasig CAS server, by default, ships with a mode that accepts
      # username=password and rejects everything else.  This is good enough for
      # testing, and I really don't want to mess with the CAS server's byzantine
      # configuration, so we are now done.
    end

    task :configure_jetty do
      # Generate a keystore.
      sh "openssl pkcs12 -inkey '#{KEY_FILE}' -in '#{CERT_FILE}' -export -out '#{JETTY_DIR}/jetty.pkcs12' -password 'pass:#{STOREPASS}'"
      sh "keytool -destkeystore '#{KEYSTORE}' -importkeystore -srckeystore '#{JETTY_DIR}/jetty.pkcs12' -srcstoretype PKCS12 -srcstorepass '#{STOREPASS}' -storepass '#{STOREPASS}' -noprompt"

      # Configure Jetty with our keystore.
      template = File.read(File.expand_path('../jetty.xml.erb', __FILE__))
      jetty_ssl_xml = ERB.new(template).result(binding)

      File.open(JETTY_SSL_CONFIG, 'w') { |f| f.write(jetty_ssl_xml) }

      ini = File.read("#{JETTY_DIR}/start.ini")

      unless ini.include?(JETTY_SSL_CONFIG)
        File.open("#{JETTY_DIR}/start.ini", 'a+') do |f|
          f.write(JETTY_SSL_CONFIG)
        end
      end

      # Delete the default connector.
      patchfile = File.expand_path('../jetty.xml.patch', __FILE__)

      cd "#{JETTY_DIR}/etc" do
        sh "patch -p1 < #{patchfile}"
      end
    end
  end
end
