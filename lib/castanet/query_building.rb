require 'castanet'

module Castanet
  ##
  # Contains a method to build query strings.
  module QueryBuilding
    ##
    # Generates query strings.
    #
    # Given a list of the form
    # 
    #     [ [k1, v1],
    #       ...
    #       [kn, vn]
    #     ]
    #
    # produces the query string
    #     
    #     e(k1)=e(v1)&...&e(kn)=e(vn)
    #
    # where `e` is a function that escapes strings for query strings.  The
    # implementation of `e` in this module is the `escape` method from
    # `Rack::Utils`.
    #
    # Key-value pairs that have null values will be removed from the query
    # string.
    #
    # @param [Array<Array<String>>] key_value_pairs an array of key-value pairs
    def query(*key_value_pairs)
      key_value_pairs.reject { |_, v| !v }.
        map { |x, y| escape(x) + '=' + escape(y) }.join('&')
    end

    private
  
    ##
    # From Rack::Utils v1.2.1.
    #
    # Copied here to avoid dragging in all of Rack for just this method.
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
  
    # Returns the bytesize of String; uses String#size under Ruby 1.8 and
    # String#bytesize under 1.9.
    #
    # Also taken from Rack::Utils v1.2.1.
    if ''.respond_to?(:bytesize)
      def bytesize(string)
        string.bytesize
      end
    else
      def bytesize(string)
        string.size
      end
    end
  end
end
