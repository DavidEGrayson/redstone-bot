require_relative 'redstone-bot.rb'

class DavidBot < Bot
  include JumpsOnCommand
	
	def handle_respawn(fields)
		super
		chat "#{username} is here!"
	end
	
	def handle_chat(message)
		super
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