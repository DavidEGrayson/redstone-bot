require_relative 'redstone-bot'
require_relative 'entity_tracker'

module EvaluatesRuby
	# Vulnerabilities:
	#   Thread.new { while true; end }
	#   "eval " + string
	#   EvaluatesRuby.instance_method(:handle_chat).bind(self).call(message)
	def handle_chat(message)
		if message.is_a?(UserChatMessage) && message.contents =~ /^eval (.+)/
			string = $1
			result = nil
			thread = Thread.new do
				$SAFE = 4
				result = begin
					eval string
				rescue Exception => e
					e.message
				end
			end
			if !thread.join(0.5)
				thread.kill
				result = ":("
			end
			
			begin
				case result
					when String then chat result
					when nil then
					else chat result.inspect
					end
			rescue SecurityError => e
				chat e.message 
			end
			
			GC.enable
		end
	end
end

module GreetsElavid
	def handle_chat(message)
		if message.is_a?(ColoredMessage) && message.contents == "Elavid joined the game."
			later(3) do
			  chat 'WOOHOO Elavid is here!'
			end
		end
	end
end

class DavidBot < Bot
  include JumpsOnCommand
	include GreetsElavid
	include EvaluatesRuby
	include EntityTracker
	
	def handle_respawn(fields)
		chat "#{username} is here!"
	end
	
	def handle_chat(message)
		respond_to_death_message message
		respond_to_hit_command message
	end
	
	def respond_to_hit_command(message)
		return unless message.is_a?(UserChatMessage)
		if message.contents =~ /hit (.*)/
			name = $1
			eid, entity = entities.find{ |id,e| e.name == name }
			if entity
				chat "OK, hitting #{entity}"
				Thread.new do
					(10*5).times do 
						synchronize { hit(entity) }
						sleep 0.2
					end
				end
			else
				chat "Who?"
			end
		end
	end
	
	def respond_to_death_message(message)
		return unless message.is_a?(DeathMessage)
		return if message.username == username
		response = case message.death_type
			when :drowned then "Swimming is fun, right #{message.username}?"
			when :hit_ground then "That sounds painful."
			when :slain, :shot, :killed then "Way to go, #{message.killer_name}!"
			when :fell_out then nil
			when :lava, :flames, :burned then "#{message.username} in oven.  No turn on."
			when :blew_up then "KABOOM!!!!"
			when :fireballed then nil
			when :magic then nil
			when :suffocated then "Watch out for dangerous walls, #{message.username}!"
			when :pricked then "WOW, FOR REAL #{message.username.upcase}??"
			when :arrow then "Happy Valentines Day, #{message.username}."
			when :died then "R.I.P. #{message.username}"
			when :no_chance then "I thought #{message.username} had a chance."
			end
			
		chat response if response
	end
end

DavidBot.new.run