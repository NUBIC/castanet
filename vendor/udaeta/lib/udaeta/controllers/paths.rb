require 'udaeta'

module Udaeta::Controllers
  module Paths
    def gemfile
      File.expand_path('../../servers/Gemfile', __FILE__)
    end

    def common_root
      File.expand_path('../../servers/common', __FILE__)
    end
  end
end
