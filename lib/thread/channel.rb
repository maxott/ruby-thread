#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

require 'thread'

# A channel lets you send and receive various messages in a thread-safe way.
#
# It also allows for guards upon sending and retrieval, to ensure the passed
# messages are safe to be consumed.
class Thread::Channel
	# Create a channel with optional initial messages and optional channel guard.
	def initialize (messages = [], &block)
		@messages = []
		@mutex    = Mutex.new
		@cond     = ConditionVariable.new
		@check    = block

		messages.each {|o|
			send o
		}
	end

	# Send a message to the channel.
	#
	# If there's a guard, the value is passed to it, if the guard returns a falsy value
	# an ArgumentError exception is raised and the message is not sent.
	def send (what)
		if @check && !@check.call(what)
			raise ArgumentError, 'guard mismatch'
		end

		@mutex.synchronize {
			@messages << what
			@cond.broadcast
		}

		self
	end

	# Receive a message, if there are none the call blocks until there's one.
	#
	# If a block is passed, it's used as guard to match to a message.
	def receive (&block)
		message = nil

		if block
			found = false

			until found
				@mutex.synchronize {
					if index = @messages.find_index(&block)
						message = @messages.delete_at(index)
						found   = true
					else
						@cond.wait @mutex
					end
				}
			end
		else
			@mutex.synchronize {
				if @messages.empty?
					@cond.wait @mutex
				end

				message = @messages.shift
			}
		end

		message
	end

	# Receive a message, if there are none the call returns nil.
	#
	# If a block is passed, it's used as guard to match to a message.
	def receive! (&block)
		if block
			@messages.delete_at(@messages.find_index(&block))
		else
			@messages.shift
		end
	end
end
