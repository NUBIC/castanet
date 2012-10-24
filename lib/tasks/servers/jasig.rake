require 'yaml'

# This is a ridiculous amount of setup for a CAS server.

namespace :servers do
  namespace :jasig do
    JASIG_URL = 'http://downloads.jasig.org/cas/cas-server-3.5.0-release.tar.gz'
    JETTY_URL = 'http://ftp.osuosl.org/pub/eclipse/jetty/stable-8/dist/jetty-distribution-8.1.5.v20120716.tar.gz'

    JASIG_PORT = 51983

    JASIG_DIR = "#{DOWNLOAD_DIR}/jasig-cas"
    JETTY_DIR = "#{DOWNLOAD_DIR}/jetty"
    KEYSTORE = "#{JETTY_DIR}/jetty.ks"
    JETTY_SSL_CONFIG = "#{JETTY_DIR}/etc/jetty-cas-ssl.xml"
    
    STOREPASS = 'secret'

    desc 'Start the Jasig CAS server for integration tests'
    task :start do
      Dir.chdir(JETTY_DIR) do
        Kernel.exec 'java',
          "-jar",
          "start.jar"
      end
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

        sh "wget #{url} -O #{dest_file}" if !File.exists?(dest_file)
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

      # Tell Jetty to use the keystore.
      jetty_ssl_xml = %Q{
<?xml version="1.0"?>
<!DOCTYPE Configure PUBLIC "-//Jetty//Configure//EN" "http://www.eclipse.org/jetty/configure.dtd">
<Configure id="Server" class="org.eclipse.jetty.server.Server">
  <New id="sslContextFactory" class="org.eclipse.jetty.http.ssl.SslContextFactory">
    <Set name="KeyStore">#{KEYSTORE}</Set>
    <Set name="KeyStorePassword">#{STOREPASS}</Set>
    <Set name="TrustStore">#{KEYSTORE}</Set>
    <Set name="TrustStorePassword">#{STOREPASS}</Set>
  </New>
  <Call class="java.lang.System" name="setProperty">
    <Arg>javax.net.ssl.trustStore</Arg>
    <Arg>#{KEYSTORE}</Arg>
  </Call>
  <Call class="java.lang.System" name="setProperty">
    <Arg>javax.net.ssl.trustStorePassword</Arg>
    <Arg>#{STOREPASS}</Arg>
  </Call>
  <Call name="addConnector">
    <Arg>
      <New class="org.eclipse.jetty.server.ssl.SslSelectChannelConnector">
        <Arg><Ref id="sslContextFactory" /></Arg>
        <Set name="Port">
          <Property name="jetty.ssl_port" default="8443" />
        </Set>
        <Set name="maxIdleTime">30000</Set>
        <Set name="Acceptors">2</Set>
        <Set name="AcceptQueueSize">100</Set>
      </New>
    </Arg>
  </Call>
</Configure>
      }.strip

      File.open(JETTY_SSL_CONFIG, 'w') { |f| f.write(jetty_ssl_xml) }

      ini = File.read("#{JETTY_DIR}/start.ini")

      unless ini.include?(JETTY_SSL_CONFIG)
        File.open("#{JETTY_DIR}/start.ini", 'a+') do |f|
          f.write(JETTY_SSL_CONFIG)
        end
      end
    end
  end
end
