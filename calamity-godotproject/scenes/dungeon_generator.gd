extends Node2D

@export var room_scenes: Array = []
var used_positions = {}

func _ready():
	generate_dungeon()
	
func generate_dungeon():
	# Initialize the starting room
	var start_room = instance_room()
	start_room.position = Vector2.ZERO  # Starting at (0, 0)
	add_child(start_room)
	used_positions[start_room.position] = start_room

	# Start placing connected rooms
	place_connected_rooms(start_room, 5)  # Adjust number of rooms


#func drop_items():
	#var item_instance = coin_bag.instantiate()
	#item_instance.global_position = $Marker2D.global_position
	#get_parent().add_child(item_instance)
	
	
func instance_room() -> Node2D:
	# Choose a random room scene to instance
	var scene = room_scenes[randi() % room_scenes.size()]
	return scene.instantiate()

func place_connected_rooms(current_room: Node2D, remaining_rooms: int):
	if remaining_rooms <= 0:
		return

	# Get available door positions
	var doors = get_door_markers(current_room)
	for door in doors:
		# Position of the new room based on the door's position
		var target_position = current_room.global_position + door.global_position

		if used_positions.has(target_position):
			continue  # Skip if there's already a room here

		var new_room = instance_room()
		add_child(new_room)
		new_room.global_position = target_position
		used_positions[target_position] = new_room

		# Recursively place more rooms
		place_connected_rooms(new_room, remaining_rooms - 1)

func get_door_markers(room: Node2D) -> Array:
	var door_markers = []
	for child in room.get_children():
		if child is Marker2D and child.name.begins_with("Door"):
			door_markers.append(child)
	return door_markers
