extends Node2D

@export var room_scenes: Array = []
var player = preload("res://scenes/player.tscn")
var enemy = preload("res://scenes/enemy.tscn")
var used_positions = {}
var door_distance_offsets = {}
const NUM_ROOMS = 5

func _ready():
	generate_dungeon()
	#place_player()
	#place_enemies(10)
	
func calculate_door_distance_offsets(current_room: Node2D):
	var room_pos = current_room.global_position
	var current_doors = get_door_markers(current_room)
	for door in current_doors:
		var pos = door.global_position
		door_distance_offsets[door.name] = pos - room_pos
	
func _process(delta):
	# Check for Cmd+R or Ctrl+R press to restart the scene
	if Input.is_action_pressed("restart_scene"):
		restart_scene()
		
func restart_scene():
	# Reload the current scene
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()
	
func place_player():
	# Create and position the player
	var player_instance = player.instantiate()
	player_instance.position = Vector2(500, 1000)  #set position
	add_child(player_instance)
	
func place_enemies(count: int):
	for i in range(count):
		# Create and position the enemy
		var enemy_instance = enemy.instantiate()
		enemy_instance.position = Vector2(randi_range(0, 700), randi_range(0, 700))  #set position
		add_child(enemy_instance)
	
func generate_dungeon():
	# Initialize the starting room
	var start_room = instance_room()
	start_room.position = Vector2(500,1000)
	add_child(start_room)
	
	used_positions[start_room.position] = start_room
	calculate_door_distance_offsets(start_room)
	# Start placing connected rooms
	place_connected_rooms(start_room, NUM_ROOMS)  # Adjust number of rooms

	
func instance_room() -> Node2D:
	# Choose a random room scene to instance
	var scene = room_scenes[randi() % room_scenes.size()]
	return scene.instantiate()


func place_connected_rooms(current_room: Node2D, remaining_rooms: int):
	if remaining_rooms <= 0:
		return

	var current_doors = get_door_markers(current_room)
	while current_doors.size() > 0:
		# pick a random side
		var random_index = randi_range(0, current_doors.size() - 1)
		var door = current_doors[random_index]
		current_doors.remove_at(random_index) # pop
		
		var pos = door.global_position
		var new_room = instance_room()
		var new_room_pos = current_room.global_position
		
		if door.name.begins_with("D1"):
			new_room.global_position = new_room_pos - Vector2(0,door_distance_offsets["D3"].y)
		elif door.name.begins_with("D2"):
			new_room.global_position = new_room_pos + Vector2(door_distance_offsets["D2"].x,0)
		elif door.name.begins_with("D3"):
			new_room.global_position = new_room_pos + Vector2(0, door_distance_offsets["D3"].y)
		elif door.name.begins_with("D4"):
			new_room.global_position = new_room_pos - Vector2(door_distance_offsets["D2"].x, 0)
			
		if used_positions.has(new_room.global_position):
			continue  # Skip if there's already a connection here
				
		add_child(new_room)
		used_positions[new_room.global_position] = new_room

		# Recursively place more rooms
		place_connected_rooms(new_room, remaining_rooms - 1)

func get_door_markers(room: Node2D) -> Array:
	var door_markers = []
	for child in room.get_children():
		if child is Marker2D and child.name.begins_with("D"):
			door_markers.append(child)
	#print("Getting this room's doors:")
	#print(room)
	#print("door markers:")
	#print(door_markers)
	return door_markers
