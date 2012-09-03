DOWNLOAD_DIR = File.expand_path('../../../tmp', __FILE__)
CERT_FILE = File.expand_path('../../../features/support/test.crt', __FILE__)
KEY_FILE = File.expand_path('../../../features/support/test.key', __FILE__)

namespace :servers do
  desc 'Remove all test CAS servers'
  task :reset do
    rm_rf DOWNLOAD_DIR
  end
end

load File.expand_path('../servers/callback.rake', __FILE__)
load File.expand_path('../servers/jasig.rake', __FILE__)
