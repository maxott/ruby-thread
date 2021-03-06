#--
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#++

# A delay is an object that incapsulates a block which is called upon
# value retrieval, and its result cached.
class Thread::Delay
	def initialize (&block)
		@block = block
	end

	# Check if an exception has been raised.
	def exception?
		instance_variable_defined? :@exception
	end

	# Return the raised exception.
	def exception
		@exception
	end

	# Check if the delay has been called.
	def delivered?
		instance_variable_defined? :@value
	end

	alias realized? delivered?

	# Get the value of the delay, if it's already been executed, return the
	# cached result, otherwise execute the block and return the value.
	#
	# In case the block raises an exception, it will be raised, the exception is
	# cached and will be raised every time you access the value.
	def value
		raise @exception if exception?

		return @value if realized?

		begin
			@value = @block.call
		rescue Exception => e
			@exception = e

			raise
		end
	end

	alias ~ value

	# Do the same as {#value}, but return nil in case of exception.
	def value!
		begin
			value
		rescue Exception
			nil
		end
	end

	alias ! value!
end

module Kernel
	# Helper to create a Thread::Delay
	def delay (&block)
		Thread::Delay.new(&block)
	end
end
