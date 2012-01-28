



module Castanet::Responses
  ##
  # A parsed representation of responses from `/proxy`.
  #
  # The code in this class implements a state machine generated by Ragel.  The
  # state machine definition is in proxy.rl.
  class Proxy
    ##
    # Whether or not a proxy ticket could be issued.
    #
    # @return [Boolean]
    attr_accessor :ok

    alias_method :ok?, :ok

    ##
    # The proxy ticket issued by the CAS server.
    #
    # If {#ok} is false, this will be `nil`.
    #
    # @return [String, nil]
    attr_accessor :ticket

    ##
    # On ticket issuance failure, contains the code identifying the
    # nature of the failure.
    #
    # On success, is nil.
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol, sections 2.7.2 and 2.7.3
    # @return [String, nil]
    attr_accessor :failure_code

    ##
    # On ticket issuance failure, contains the failure reason.
    #
    # On success, is nil.
    #
    # @see http://www.jasig.org/cas/protocol CAS protocol, section 2.7.2
    # @return [String, nil]
    attr_accessor :failure_reason

    ##
    # Generates a {Proxy} object from a CAS response.
    #
    # @param [String] response the CAS response
    # @return [Proxy]
    def self.from_cas(response)
      data = response.strip.unpack('U*')
      buffer = ''

      
begin
	p ||= 0
	pe ||= data.length
	cs = proxy_start
end


      new.tap do |r|
        
begin
	_klen, _trans, _keys, _acts, _nacts = nil
	_goto_level = 0
	_resume = 10
	_eof_trans = 15
	_again = 20
	_test_eof = 30
	_out = 40
	while true
	_trigger_goto = false
	if _goto_level <= 0
	if p == pe
		_goto_level = _test_eof
		next
	end
	if cs == 0
		_goto_level = _out
		next
	end
	end
	if _goto_level <= _resume
	_keys = _proxy_key_offsets[cs]
	_trans = _proxy_index_offsets[cs]
	_klen = _proxy_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _proxy_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _proxy_trans_keys[_mid]
	           _lower = _mid + 1
	        else
	           _trans += (_mid - _keys)
	           _break_match = true
	           break
	        end
	     end # loop
	     break if _break_match
	     _keys += _klen
	     _trans += _klen
	  end
	  _klen = _proxy_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _proxy_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _proxy_trans_keys[_mid+1]
	          _lower = _mid + 2
	        else
	          _trans += ((_mid - _keys) >> 1)
	          _break_match = true
	          break
	        end
	     end # loop
	     break if _break_match
	     _trans += _klen
	  end
	end while false
	cs = _proxy_trans_targs[_trans]
	if _proxy_trans_actions[_trans] != 0
		_acts = _proxy_trans_actions[_trans]
		_nacts = _proxy_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _proxy_actions[_acts - 1]
when 0 then
		begin
 buffer << data[p].ord 		end
when 1 then
		begin
 r.failure_code = buffer; buffer = '' 		end
when 2 then
		begin
 r.failure_reason = buffer.strip; buffer = '' 		end
when 3 then
		begin
 r.ticket = buffer; buffer = '' 		end
when 4 then
		begin
 r.ok = true 		end
			end # action switch
		end
	end
	if _trigger_goto
		next
	end
	end
	if _goto_level <= _again
	if cs == 0
		_goto_level = _out
		next
	end
	p += 1
	if p != pe
		_goto_level = _resume
		next
	end
	end
	if _goto_level <= _test_eof
	end
	if _goto_level <= _out
		break
	end
	end
	end

      end
    end

    
class << self
	attr_accessor :_proxy_actions
	private :_proxy_actions, :_proxy_actions=
end
self._proxy_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4
]

class << self
	attr_accessor :_proxy_key_offsets
	private :_proxy_key_offsets, :_proxy_key_offsets=
end
self._proxy_key_offsets = [
	0, 0, 1, 2, 3, 4, 5, 6, 
	7, 8, 9, 10, 11, 12, 13, 14, 
	15, 16, 17, 18, 19, 20, 21, 22, 
	23, 24, 25, 26, 27, 28, 29, 30, 
	31, 33, 34, 35, 36, 37, 38, 39, 
	40, 41, 42, 43, 44, 45, 46, 47, 
	48, 49, 50, 51, 52, 53, 54, 55, 
	56, 57, 58, 59, 61, 62, 66, 67, 
	68, 69, 70, 71, 72, 73, 74, 75, 
	77, 78, 79, 80, 81, 82, 83, 84, 
	85, 86, 87, 88, 89, 91, 96, 97, 
	100, 101, 102, 103, 104, 105, 106, 107, 
	108, 109, 110, 111, 112, 113, 114, 115, 
	116, 117, 118, 122, 123, 124, 125, 126, 
	127, 128, 129, 130, 131, 132, 133, 134, 
	135, 136, 137, 138, 139, 140, 141, 142, 
	143, 146, 150, 151, 152, 153, 154, 155, 
	156, 157, 161, 162, 163, 164, 165, 166, 
	167, 168, 169, 170, 171, 172, 173, 174, 
	175, 176, 177, 185, 186, 187, 188, 189, 
	190, 191, 192, 193, 194, 195, 196, 197, 
	198, 199, 200, 201, 202, 206, 210, 211, 
	212, 213, 214, 215, 216, 217, 218, 219, 
	220, 221, 222, 223, 224, 225, 226, 227, 
	228, 232, 233, 234, 235, 236, 237, 238, 
	239, 240, 241, 242, 243, 244, 245, 246, 
	247, 248, 249, 250, 251, 252, 253
]

class << self
	attr_accessor :_proxy_trans_keys
	private :_proxy_trans_keys, :_proxy_trans_keys=
end
self._proxy_trans_keys = [
	60, 99, 97, 115, 58, 115, 101, 114, 
	118, 105, 99, 101, 82, 101, 115, 112, 
	111, 110, 115, 101, 32, 120, 109, 108, 
	110, 115, 58, 99, 97, 115, 61, 34, 
	39, 104, 116, 116, 112, 58, 47, 47, 
	119, 119, 119, 46, 121, 97, 108, 101, 
	46, 101, 100, 117, 47, 116, 112, 47, 
	99, 97, 115, 34, 39, 62, 32, 60, 
	9, 13, 99, 97, 115, 58, 112, 114, 
	111, 120, 121, 70, 83, 97, 105, 108, 
	117, 114, 101, 32, 99, 111, 100, 101, 
	61, 34, 39, 34, 39, 95, 65, 90, 
	62, 38, 60, 93, 47, 99, 97, 115, 
	58, 112, 114, 111, 120, 121, 70, 97, 
	105, 108, 117, 114, 101, 62, 32, 60, 
	9, 13, 47, 99, 97, 115, 58, 115, 
	101, 114, 118, 105, 99, 101, 82, 101, 
	115, 112, 111, 110, 115, 101, 62, 38, 
	60, 93, 38, 60, 62, 93, 117, 99, 
	99, 101, 115, 115, 62, 32, 60, 9, 
	13, 99, 97, 115, 58, 112, 114, 111, 
	120, 121, 84, 105, 99, 107, 101, 116, 
	62, 45, 60, 48, 57, 65, 90, 97, 
	122, 47, 99, 97, 115, 58, 112, 114, 
	111, 120, 121, 84, 105, 99, 107, 101, 
	116, 62, 32, 60, 9, 13, 32, 60, 
	9, 13, 47, 99, 97, 115, 58, 112, 
	114, 111, 120, 121, 83, 117, 99, 99, 
	101, 115, 115, 62, 32, 60, 9, 13, 
	47, 99, 97, 115, 58, 115, 101, 114, 
	118, 105, 99, 101, 82, 101, 115, 112, 
	111, 110, 115, 101, 62, 0
]

class << self
	attr_accessor :_proxy_single_lengths
	private :_proxy_single_lengths, :_proxy_single_lengths=
end
self._proxy_single_lengths = [
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 3, 1, 3, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	3, 4, 1, 1, 1, 1, 1, 1, 
	1, 2, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 0
]

class << self
	attr_accessor :_proxy_range_lengths
	private :_proxy_range_lengths, :_proxy_range_lengths=
end
self._proxy_range_lengths = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 3, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_proxy_index_offsets
	private :_proxy_index_offsets, :_proxy_index_offsets=
end
self._proxy_index_offsets = [
	0, 0, 2, 4, 6, 8, 10, 12, 
	14, 16, 18, 20, 22, 24, 26, 28, 
	30, 32, 34, 36, 38, 40, 42, 44, 
	46, 48, 50, 52, 54, 56, 58, 60, 
	62, 65, 67, 69, 71, 73, 75, 77, 
	79, 81, 83, 85, 87, 89, 91, 93, 
	95, 97, 99, 101, 103, 105, 107, 109, 
	111, 113, 115, 117, 120, 122, 126, 128, 
	130, 132, 134, 136, 138, 140, 142, 144, 
	147, 149, 151, 153, 155, 157, 159, 161, 
	163, 165, 167, 169, 171, 174, 179, 181, 
	185, 187, 189, 191, 193, 195, 197, 199, 
	201, 203, 205, 207, 209, 211, 213, 215, 
	217, 219, 221, 225, 227, 229, 231, 233, 
	235, 237, 239, 241, 243, 245, 247, 249, 
	251, 253, 255, 257, 259, 261, 263, 265, 
	267, 271, 276, 278, 280, 282, 284, 286, 
	288, 290, 294, 296, 298, 300, 302, 304, 
	306, 308, 310, 312, 314, 316, 318, 320, 
	322, 324, 326, 332, 334, 336, 338, 340, 
	342, 344, 346, 348, 350, 352, 354, 356, 
	358, 360, 362, 364, 366, 370, 374, 376, 
	378, 380, 382, 384, 386, 388, 390, 392, 
	394, 396, 398, 400, 402, 404, 406, 408, 
	410, 414, 416, 418, 420, 422, 424, 426, 
	428, 430, 432, 434, 436, 438, 440, 442, 
	444, 446, 448, 450, 452, 454, 456
]

class << self
	attr_accessor :_proxy_trans_targs
	private :_proxy_trans_targs, :_proxy_trans_targs=
end
self._proxy_trans_targs = [
	2, 0, 3, 0, 4, 0, 5, 0, 
	6, 0, 7, 0, 8, 0, 9, 0, 
	10, 0, 11, 0, 12, 0, 13, 0, 
	14, 0, 15, 0, 16, 0, 17, 0, 
	18, 0, 19, 0, 20, 0, 21, 0, 
	22, 0, 23, 0, 24, 0, 25, 0, 
	26, 0, 27, 0, 28, 0, 29, 0, 
	30, 0, 31, 0, 32, 0, 33, 33, 
	0, 34, 0, 35, 0, 36, 0, 37, 
	0, 38, 0, 39, 0, 40, 0, 41, 
	0, 42, 0, 43, 0, 44, 0, 45, 
	0, 46, 0, 47, 0, 48, 0, 49, 
	0, 50, 0, 51, 0, 52, 0, 53, 
	0, 54, 0, 55, 0, 56, 0, 57, 
	0, 58, 0, 59, 0, 60, 60, 0, 
	61, 0, 61, 62, 61, 0, 63, 0, 
	64, 0, 65, 0, 66, 0, 67, 0, 
	68, 0, 69, 0, 70, 0, 71, 0, 
	72, 130, 0, 73, 0, 74, 0, 75, 
	0, 76, 0, 77, 0, 78, 0, 79, 
	0, 80, 0, 81, 0, 82, 0, 83, 
	0, 84, 0, 85, 85, 0, 86, 86, 
	85, 85, 0, 87, 0, 0, 88, 128, 
	87, 89, 0, 90, 0, 91, 0, 92, 
	0, 93, 0, 94, 0, 95, 0, 96, 
	0, 97, 0, 98, 0, 99, 0, 100, 
	0, 101, 0, 102, 0, 103, 0, 104, 
	0, 105, 0, 106, 0, 106, 107, 106, 
	0, 108, 0, 109, 0, 110, 0, 111, 
	0, 112, 0, 113, 0, 114, 0, 115, 
	0, 116, 0, 117, 0, 118, 0, 119, 
	0, 120, 0, 121, 0, 122, 0, 123, 
	0, 124, 0, 125, 0, 126, 0, 127, 
	0, 214, 0, 0, 88, 129, 87, 0, 
	88, 0, 129, 87, 131, 0, 132, 0, 
	133, 0, 134, 0, 135, 0, 136, 0, 
	137, 0, 137, 138, 137, 0, 139, 0, 
	140, 0, 141, 0, 142, 0, 143, 0, 
	144, 0, 145, 0, 146, 0, 147, 0, 
	148, 0, 149, 0, 150, 0, 151, 0, 
	152, 0, 153, 0, 154, 0, 154, 155, 
	154, 154, 154, 0, 156, 0, 157, 0, 
	158, 0, 159, 0, 160, 0, 161, 0, 
	162, 0, 163, 0, 164, 0, 165, 0, 
	166, 0, 167, 0, 168, 0, 169, 0, 
	170, 0, 171, 0, 172, 0, 173, 174, 
	173, 0, 173, 174, 173, 0, 175, 0, 
	176, 0, 177, 0, 178, 0, 179, 0, 
	180, 0, 181, 0, 182, 0, 183, 0, 
	184, 0, 185, 0, 186, 0, 187, 0, 
	188, 0, 189, 0, 190, 0, 191, 0, 
	192, 0, 192, 193, 192, 0, 194, 0, 
	195, 0, 196, 0, 197, 0, 198, 0, 
	199, 0, 200, 0, 201, 0, 202, 0, 
	203, 0, 204, 0, 205, 0, 206, 0, 
	207, 0, 208, 0, 209, 0, 210, 0, 
	211, 0, 212, 0, 213, 0, 214, 0, 
	0, 0
]

class << self
	attr_accessor :_proxy_trans_actions
	private :_proxy_trans_actions, :_proxy_trans_actions=
end
self._proxy_trans_actions = [
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 3, 3, 
	1, 1, 0, 0, 0, 0, 5, 1, 
	1, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 5, 1, 1, 0, 
	5, 0, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	1, 1, 1, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 7, 7, 
	7, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 9, 0, 
	0, 0
]

class << self
	attr_accessor :proxy_start
end
self.proxy_start = 1;
class << self
	attr_accessor :proxy_first_final
end
self.proxy_first_final = 214;
class << self
	attr_accessor :proxy_error
end
self.proxy_error = 0;

class << self
	attr_accessor :proxy_en_main
end
self.proxy_en_main = 1;


  end
end
