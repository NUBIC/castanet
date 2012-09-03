



module Castanet::Responses
  ##
  # A parsed representation of responses from `/serviceValidate` or
  # `/proxyValidate`.
  #
  # The responses for the above services are identical, so we implement their
  # parser with the same state machine.
  #
  # The code in this class implements a state machine generated by Ragel.  The
  # state machine definition is in ticket_validate.rl.
  #
  # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, sections 2.5, 2.6,
  #   and appendix A
  class TicketValidate
    ##
    # Whether or not this response passed CAS authentication.
    #
    # @return [Boolean]
    attr_accessor :ok

    alias_method :ok?, :ok

    ##
    # The failure code returned on authentication failure.
    #
    # @return [String, nil]
    attr_accessor :failure_code

    ##
    # The reason given by the CAS server for authentication failure.
    #
    # @return [String, nil]
    attr_accessor :failure_reason

    ##
    # The PGT IOU returned by an authentication success message.
    #
    # @return [String, nil]
    attr_accessor :pgt_iou

    ##
    # A list of authentication proxies for this ticket.
    #
    # Each participant in an authentication chain adds one entry to this list.
    # As an example, assume the existence of two services:
    #
    # 1. frontend
    # 2. backend
    #
    # If `frontend` proxied access to `backend`, the proxy list would be
    #
    # 1. backend
    # 2. frontend
    #
    # The proxy chain has an unbounded maximum length.  The proxy order
    # specified in the CAS response is preserved.
    #
    # For proxy tickets that fail validation, this will be an empty list.  It
    # should also be an empty list for service tickets too, although that's
    # really up to the CAS server.
    #
    # Although this list is technically a valid component of an authentication
    # response issued by `/serviceValidate`, it's really only applicable to
    # proxy tickets.
    #
    # @see http://www.jasig.org/cas/protocol CAS 2.0 protocol, section 2.6.2
    # @return [Array]
    attr_accessor :proxies

    ##
    # The name of the owner of the validated service or proxy ticket.
    #
    # This information is only present on authentication success.
    #
    # @return [String, nil]
    attr_accessor :username

    ##
    # Generates a {TicketValidate} object from a CAS response.
    #
    # @param [String, nil] response the CAS response
    # @return [TicketValidate}
    def self.from_cas(response)
      data = response.to_s.strip.unpack('U*')
      buffer = ''

      
begin
	p ||= 0
	pe ||= data.length
	cs = ticket_validate_start
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
	_keys = _ticket_validate_key_offsets[cs]
	_trans = _ticket_validate_index_offsets[cs]
	_klen = _ticket_validate_single_lengths[cs]
	_break_match = false
	
	begin
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + _klen - 1

	     loop do
	        break if _upper < _lower
	        _mid = _lower + ( (_upper - _lower) >> 1 )

	        if data[p].ord < _ticket_validate_trans_keys[_mid]
	           _upper = _mid - 1
	        elsif data[p].ord > _ticket_validate_trans_keys[_mid]
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
	  _klen = _ticket_validate_range_lengths[cs]
	  if _klen > 0
	     _lower = _keys
	     _upper = _keys + (_klen << 1) - 2
	     loop do
	        break if _upper < _lower
	        _mid = _lower + (((_upper-_lower) >> 1) & ~1)
	        if data[p].ord < _ticket_validate_trans_keys[_mid]
	          _upper = _mid - 2
	        elsif data[p].ord > _ticket_validate_trans_keys[_mid+1]
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
	cs = _ticket_validate_trans_targs[_trans]
	if _ticket_validate_trans_actions[_trans] != 0
		_acts = _ticket_validate_trans_actions[_trans]
		_nacts = _ticket_validate_actions[_acts]
		_acts += 1
		while _nacts > 0
			_nacts -= 1
			_acts += 1
			case _ticket_validate_actions[_acts - 1]
when 0 then
		begin
 r.username = buffer; buffer = '' 		end
when 1 then
		begin
 r.failure_code = buffer; buffer = '' 		end
when 2 then
		begin
 r.failure_reason = buffer.strip; buffer = '' 		end
when 3 then
		begin
 r.pgt_iou = buffer; buffer = '' 		end
when 4 then
		begin
 r.proxies << buffer; buffer = '' 		end
when 5 then
		begin
 r.ok = true 		end
when 6 then
		begin
 buffer << data[p].ord 		end
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

    def initialize
      self.ok = false
      self.proxies = []
    end

    
class << self
	attr_accessor :_ticket_validate_actions
	private :_ticket_validate_actions, :_ticket_validate_actions=
end
self._ticket_validate_actions = [
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 1, 6
]

class << self
	attr_accessor :_ticket_validate_key_offsets
	private :_ticket_validate_key_offsets, :_ticket_validate_key_offsets=
end
self._ticket_validate_key_offsets = [
	0, 0, 1, 2, 3, 4, 5, 6, 
	7, 8, 9, 10, 11, 12, 13, 14, 
	15, 16, 17, 18, 19, 20, 21, 22, 
	23, 24, 25, 26, 27, 28, 29, 30, 
	31, 33, 34, 35, 36, 37, 38, 39, 
	40, 41, 42, 43, 44, 45, 46, 47, 
	48, 49, 50, 51, 52, 53, 54, 55, 
	56, 57, 58, 59, 61, 62, 66, 67, 
	68, 69, 70, 71, 72, 73, 74, 75, 
	76, 77, 78, 79, 80, 81, 82, 83, 
	84, 86, 87, 88, 89, 90, 91, 92, 
	93, 94, 95, 96, 97, 98, 100, 105, 
	106, 109, 110, 111, 112, 113, 114, 115, 
	116, 117, 118, 119, 120, 121, 122, 123, 
	124, 125, 126, 127, 128, 129, 130, 131, 
	132, 133, 134, 135, 136, 140, 141, 142, 
	143, 144, 145, 146, 147, 148, 149, 150, 
	151, 152, 153, 154, 155, 156, 157, 158, 
	159, 160, 161, 164, 168, 169, 170, 171, 
	172, 173, 174, 175, 179, 180, 181, 182, 
	183, 184, 185, 186, 187, 188, 191, 192, 
	193, 194, 195, 196, 197, 198, 199, 200, 
	201, 205, 209, 211, 212, 213, 214, 215, 
	216, 217, 218, 219, 220, 221, 222, 223, 
	224, 225, 226, 227, 228, 229, 230, 231, 
	232, 233, 234, 235, 236, 237, 241, 242, 
	243, 244, 245, 246, 247, 248, 249, 250, 
	251, 252, 253, 254, 255, 256, 257, 258, 
	259, 260, 261, 262, 263, 264, 265, 266, 
	267, 268, 269, 271, 272, 273, 274, 278, 
	282, 283, 284, 285, 286, 287, 288, 289, 
	290, 291, 292, 295, 296, 297, 298, 299, 
	300, 301, 302, 303, 304, 305, 306, 310, 
	314, 316, 317, 318, 319, 320, 321, 322, 
	323, 324, 325, 326, 327, 328, 332, 333, 
	336, 340, 341, 342, 343, 344, 345, 346, 
	347, 348, 349, 350, 351, 352, 353, 354, 
	355, 364, 365, 366, 367, 368, 369, 370, 
	371, 372, 373, 374, 375, 376, 377, 378, 
	379, 380, 381, 382, 383, 384, 385, 386, 
	387, 388, 389, 393, 397, 399, 400, 401, 
	402, 403, 404, 405, 406, 407, 410, 414
]

class << self
	attr_accessor :_ticket_validate_trans_keys
	private :_ticket_validate_trans_keys, :_ticket_validate_trans_keys=
end
self._ticket_validate_trans_keys = [
	60, 99, 97, 115, 58, 115, 101, 114, 
	118, 105, 99, 101, 82, 101, 115, 112, 
	111, 110, 115, 101, 32, 120, 109, 108, 
	110, 115, 58, 99, 97, 115, 61, 34, 
	39, 104, 116, 116, 112, 58, 47, 47, 
	119, 119, 119, 46, 121, 97, 108, 101, 
	46, 101, 100, 117, 47, 116, 112, 47, 
	99, 97, 115, 34, 39, 62, 32, 60, 
	9, 13, 99, 97, 115, 58, 97, 117, 
	116, 104, 101, 110, 116, 105, 99, 97, 
	116, 105, 111, 110, 70, 83, 97, 105, 
	108, 117, 114, 101, 32, 99, 111, 100, 
	101, 61, 34, 39, 34, 39, 95, 65, 
	90, 62, 38, 60, 93, 47, 99, 97, 
	115, 58, 97, 117, 116, 104, 101, 110, 
	116, 105, 99, 97, 116, 105, 111, 110, 
	70, 97, 105, 108, 117, 114, 101, 62, 
	32, 60, 9, 13, 47, 99, 97, 115, 
	58, 115, 101, 114, 118, 105, 99, 101, 
	82, 101, 115, 112, 111, 110, 115, 101, 
	62, 38, 60, 93, 38, 60, 62, 93, 
	117, 99, 99, 101, 115, 115, 62, 32, 
	60, 9, 13, 99, 97, 115, 58, 117, 
	115, 101, 114, 62, 38, 60, 93, 47, 
	99, 97, 115, 58, 117, 115, 101, 114, 
	62, 32, 60, 9, 13, 32, 60, 9, 
	13, 47, 99, 99, 97, 115, 58, 97, 
	117, 116, 104, 101, 110, 116, 105, 99, 
	97, 116, 105, 111, 110, 83, 117, 99, 
	99, 101, 115, 115, 62, 32, 60, 9, 
	13, 47, 99, 97, 115, 58, 115, 101, 
	114, 118, 105, 99, 101, 82, 101, 115, 
	112, 111, 110, 115, 101, 62, 97, 115, 
	58, 112, 114, 111, 120, 105, 121, 101, 
	115, 62, 32, 60, 9, 13, 32, 60, 
	9, 13, 99, 97, 115, 58, 112, 114, 
	111, 120, 121, 62, 38, 60, 93, 47, 
	99, 97, 115, 58, 112, 114, 111, 120, 
	121, 62, 32, 60, 9, 13, 32, 60, 
	9, 13, 47, 99, 99, 97, 115, 58, 
	112, 114, 111, 120, 105, 101, 115, 62, 
	32, 60, 9, 13, 47, 38, 60, 93, 
	38, 60, 62, 93, 71, 114, 97, 110, 
	116, 105, 110, 103, 84, 105, 99, 107, 
	101, 116, 62, 60, 45, 46, 48, 57, 
	65, 90, 97, 122, 47, 99, 97, 115, 
	58, 112, 114, 111, 120, 121, 71, 114, 
	97, 110, 116, 105, 110, 103, 84, 105, 
	99, 107, 101, 116, 62, 32, 60, 9, 
	13, 32, 60, 9, 13, 47, 99, 97, 
	115, 58, 112, 114, 111, 120, 105, 38, 
	60, 93, 38, 60, 62, 93, 0
]

class << self
	attr_accessor :_ticket_validate_single_lengths
	private :_ticket_validate_single_lengths, :_ticket_validate_single_lengths=
end
self._ticket_validate_single_lengths = [
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 3, 1, 
	3, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 3, 4, 1, 1, 1, 1, 
	1, 1, 1, 2, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 3, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 2, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 1, 1, 1, 2, 2, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 3, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 2, 2, 
	2, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 2, 1, 3, 
	4, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 2, 2, 2, 1, 1, 1, 
	1, 1, 1, 1, 1, 3, 4, 0
]

class << self
	attr_accessor :_ticket_validate_range_lengths
	private :_ticket_validate_range_lengths, :_ticket_validate_range_lengths=
end
self._ticket_validate_range_lengths = [
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	4, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 1, 1, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0
]

class << self
	attr_accessor :_ticket_validate_index_offsets
	private :_ticket_validate_index_offsets, :_ticket_validate_index_offsets=
end
self._ticket_validate_index_offsets = [
	0, 0, 2, 4, 6, 8, 10, 12, 
	14, 16, 18, 20, 22, 24, 26, 28, 
	30, 32, 34, 36, 38, 40, 42, 44, 
	46, 48, 50, 52, 54, 56, 58, 60, 
	62, 65, 67, 69, 71, 73, 75, 77, 
	79, 81, 83, 85, 87, 89, 91, 93, 
	95, 97, 99, 101, 103, 105, 107, 109, 
	111, 113, 115, 117, 120, 122, 126, 128, 
	130, 132, 134, 136, 138, 140, 142, 144, 
	146, 148, 150, 152, 154, 156, 158, 160, 
	162, 165, 167, 169, 171, 173, 175, 177, 
	179, 181, 183, 185, 187, 189, 192, 197, 
	199, 203, 205, 207, 209, 211, 213, 215, 
	217, 219, 221, 223, 225, 227, 229, 231, 
	233, 235, 237, 239, 241, 243, 245, 247, 
	249, 251, 253, 255, 257, 261, 263, 265, 
	267, 269, 271, 273, 275, 277, 279, 281, 
	283, 285, 287, 289, 291, 293, 295, 297, 
	299, 301, 303, 307, 312, 314, 316, 318, 
	320, 322, 324, 326, 330, 332, 334, 336, 
	338, 340, 342, 344, 346, 348, 352, 354, 
	356, 358, 360, 362, 364, 366, 368, 370, 
	372, 376, 380, 383, 385, 387, 389, 391, 
	393, 395, 397, 399, 401, 403, 405, 407, 
	409, 411, 413, 415, 417, 419, 421, 423, 
	425, 427, 429, 431, 433, 435, 439, 441, 
	443, 445, 447, 449, 451, 453, 455, 457, 
	459, 461, 463, 465, 467, 469, 471, 473, 
	475, 477, 479, 481, 483, 485, 487, 489, 
	491, 493, 495, 498, 500, 502, 504, 508, 
	512, 514, 516, 518, 520, 522, 524, 526, 
	528, 530, 532, 536, 538, 540, 542, 544, 
	546, 548, 550, 552, 554, 556, 558, 562, 
	566, 569, 571, 573, 575, 577, 579, 581, 
	583, 585, 587, 589, 591, 593, 597, 599, 
	603, 608, 610, 612, 614, 616, 618, 620, 
	622, 624, 626, 628, 630, 632, 634, 636, 
	638, 644, 646, 648, 650, 652, 654, 656, 
	658, 660, 662, 664, 666, 668, 670, 672, 
	674, 676, 678, 680, 682, 684, 686, 688, 
	690, 692, 694, 698, 702, 705, 707, 709, 
	711, 713, 715, 717, 719, 721, 725, 730
]

class << self
	attr_accessor :_ticket_validate_trans_targs
	private :_ticket_validate_trans_targs, :_ticket_validate_trans_targs=
end
self._ticket_validate_trans_targs = [
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
	72, 0, 73, 0, 74, 0, 75, 0, 
	76, 0, 77, 0, 78, 0, 79, 0, 
	80, 0, 81, 148, 0, 82, 0, 83, 
	0, 84, 0, 85, 0, 86, 0, 87, 
	0, 88, 0, 89, 0, 90, 0, 91, 
	0, 92, 0, 93, 0, 94, 94, 0, 
	95, 95, 94, 94, 0, 96, 0, 0, 
	97, 146, 96, 98, 0, 99, 0, 100, 
	0, 101, 0, 102, 0, 103, 0, 104, 
	0, 105, 0, 106, 0, 107, 0, 108, 
	0, 109, 0, 110, 0, 111, 0, 112, 
	0, 113, 0, 114, 0, 115, 0, 116, 
	0, 117, 0, 118, 0, 119, 0, 120, 
	0, 121, 0, 122, 0, 123, 0, 124, 
	0, 124, 125, 124, 0, 126, 0, 127, 
	0, 128, 0, 129, 0, 130, 0, 131, 
	0, 132, 0, 133, 0, 134, 0, 135, 
	0, 136, 0, 137, 0, 138, 0, 139, 
	0, 140, 0, 141, 0, 142, 0, 143, 
	0, 144, 0, 145, 0, 335, 0, 0, 
	97, 147, 96, 0, 97, 0, 147, 96, 
	149, 0, 150, 0, 151, 0, 152, 0, 
	153, 0, 154, 0, 155, 0, 155, 156, 
	155, 0, 157, 0, 158, 0, 159, 0, 
	160, 0, 161, 0, 162, 0, 163, 0, 
	164, 0, 165, 0, 0, 166, 333, 165, 
	167, 0, 168, 0, 169, 0, 170, 0, 
	171, 0, 172, 0, 173, 0, 174, 0, 
	175, 0, 176, 0, 177, 178, 177, 0, 
	177, 178, 177, 0, 179, 227, 0, 180, 
	0, 181, 0, 182, 0, 183, 0, 184, 
	0, 185, 0, 186, 0, 187, 0, 188, 
	0, 189, 0, 190, 0, 191, 0, 192, 
	0, 193, 0, 194, 0, 195, 0, 196, 
	0, 197, 0, 198, 0, 199, 0, 200, 
	0, 201, 0, 202, 0, 203, 0, 204, 
	0, 205, 0, 205, 206, 205, 0, 207, 
	0, 208, 0, 209, 0, 210, 0, 211, 
	0, 212, 0, 213, 0, 214, 0, 215, 
	0, 216, 0, 217, 0, 218, 0, 219, 
	0, 220, 0, 221, 0, 222, 0, 223, 
	0, 224, 0, 225, 0, 226, 0, 335, 
	0, 228, 0, 229, 0, 230, 0, 231, 
	0, 232, 0, 233, 0, 234, 0, 235, 
	281, 0, 236, 0, 237, 0, 238, 0, 
	239, 264, 239, 0, 239, 240, 239, 0, 
	241, 0, 242, 0, 243, 0, 244, 0, 
	245, 0, 246, 0, 247, 0, 248, 0, 
	249, 0, 250, 0, 0, 251, 279, 250, 
	252, 0, 253, 0, 254, 0, 255, 0, 
	256, 0, 257, 0, 258, 0, 259, 0, 
	260, 0, 261, 0, 262, 0, 263, 264, 
	263, 0, 263, 264, 263, 0, 265, 241, 
	0, 266, 0, 267, 0, 268, 0, 269, 
	0, 270, 0, 271, 0, 272, 0, 273, 
	0, 274, 0, 275, 0, 276, 0, 277, 
	0, 277, 278, 277, 0, 179, 0, 0, 
	251, 280, 250, 0, 251, 0, 280, 250, 
	282, 0, 283, 0, 284, 0, 285, 0, 
	286, 0, 287, 0, 288, 0, 289, 0, 
	290, 0, 291, 0, 292, 0, 293, 0, 
	294, 0, 295, 0, 296, 0, 297, 296, 
	296, 296, 296, 0, 298, 0, 299, 0, 
	300, 0, 301, 0, 302, 0, 303, 0, 
	304, 0, 305, 0, 306, 0, 307, 0, 
	308, 0, 309, 0, 310, 0, 311, 0, 
	312, 0, 313, 0, 314, 0, 315, 0, 
	316, 0, 317, 0, 318, 0, 319, 0, 
	320, 0, 321, 0, 322, 0, 323, 324, 
	323, 0, 323, 324, 323, 0, 179, 325, 
	0, 326, 0, 327, 0, 328, 0, 329, 
	0, 330, 0, 331, 0, 332, 0, 235, 
	0, 0, 166, 334, 165, 0, 166, 0, 
	334, 165, 0, 0
]

class << self
	attr_accessor :_ticket_validate_trans_actions
	private :_ticket_validate_trans_actions, :_ticket_validate_trans_actions=
end
self._ticket_validate_trans_actions = [
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
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	3, 3, 13, 13, 0, 0, 0, 0, 
	5, 13, 13, 0, 0, 0, 0, 0, 
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
	5, 13, 13, 0, 5, 0, 13, 13, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 13, 13, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 1, 1, 1, 0, 
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
	0, 0, 0, 0, 0, 0, 0, 11, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 13, 13, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 9, 9, 
	9, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 13, 13, 0, 0, 0, 13, 13, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 13, 
	13, 13, 13, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 7, 7, 
	7, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 13, 13, 0, 0, 0, 
	13, 13, 0, 0
]

class << self
	attr_accessor :ticket_validate_start
end
self.ticket_validate_start = 1;
class << self
	attr_accessor :ticket_validate_first_final
end
self.ticket_validate_first_final = 335;
class << self
	attr_accessor :ticket_validate_error
end
self.ticket_validate_error = 0;

class << self
	attr_accessor :ticket_validate_en_main
end
self.ticket_validate_en_main = 1;


  end
end
