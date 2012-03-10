require 'matrix'

class Entity
  attr_accessor :id
	attr_accessor :position  # Vector of floats	
	attr_accessor :name      # nil for non-players
end

class Player < Entity
	def initialize(id, name=nil)
		@id = id
		@name = name
	end
	
	def to_s
		"Player(#{id}, #{name.inspect}, #{position})"
	end
end

class Mob < Entity
	@mob_ids = {}       # Associates mob id (50..120) to the different Mob subclasses.
	def self.mob_ids
		@mob_ids
	end
	
	def initialize(id)
		@id = id
	end
	
	def self.mob_id(id)
		@mob_id = id
		Mob.mob_ids[id] = self
	end
	
	def self.create(id, type)
		(Mob.mob_ids[type] || Mob).new(id)
	end

	def to_s
		"#{self.class.name}(#{id}, #{position})"
	end
end

def Mob(id)
	klass = Class.new(Mob)
	klass.mob_id id
	klass
end

class Creeper < Mob
	mob_id 50
end

class Chicken < Mob
	mob_id 93
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
		entities[fields[:eid]] = Player.new fields[:eid], fields[:player_name]
		update_entity_position_absolute fields
	end
	
	def handle_mob_spawn(fields)
		entities[fields[:eid]] = Mob.create fields[:eid], fields[:type]
		update_entity_position_absolute fields
		# Note: we are ignoring fields :yaw, :pitch, :head yaw, and metadata.
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