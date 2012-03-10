require 'matrix'

class Entity
  attr_accessor :id
	attr_accessor :name
	attr_accessor :position  # Vector of floats
	
	def initialize(id, name)
		@id = id
		@name = name
	end
	
	def to_s
		"Entity(#{id}, #{name.inspect}, #{position})"
	end
end

module EntityTracker
	def entities
		@entities ||= {}
	end
	
	def closest_entity
		@entities.values.min_by { |e| distance_to(e.position) }
	end
	
	def distance_to(position)
		(position - position_vector).magnitude
	end
	
	def update_entity_position_absolute(fields)
		return unless entities.has_key?(fields[:eid])
		entities[fields[:eid]].position = Vector[fields[:x], fields[:y], fields[:z]] / 32.0
	end

	def update_entity_position_relative(fields)
		return unless entities.has_key?(fields[:eid])
		entities[fields[:eid]].position += Vector[fields[:dx], fields[:dy], fields[:dz]] / 32.0
	end

	def position_vector
		Vector[@position[:x], @position[:y], @position[:z]]
	end
	
	def handle_player_position_and_look(fields)
	end

	def handle_named_entity_spawn(fields)
		entities[fields[:eid]] = Entity.new fields[:eid], fields[:player_name]
		update_entity_position_absolute fields
	end
	
	def handle_entity_relative_move(fields)
		update_entity_position_relative fields
	end

	def handle_entity_look_and_relative_move(fields)
		update_entity_position_relative fields
	end

	def handle_entity_teleport(fields)
		update_entity_position_absolute fields
	end

	def handle_destroy_entity(fields)
		entities.delete fields[:eid]
	end
end