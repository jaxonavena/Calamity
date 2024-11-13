extends Node2D

@export var room_scenes: Array = []
var player = preload("res://scenes/player.tscn")
var enemy = preload("res://scenes/enemy.tscn")
var used_positions = {}

func _ready():
	generate_dungeon()
	place_player()
	place_enemies(10)
	
func _process(delta):
	# Check for Cmd+R or Ctrl+R press to restart the scene
	if Input.is_action_just_pressed("restart_scene"):
		restart_scene()
	
func restart_scene():
	# Reload the current scene
	var current_scene = get_tree().current_scene
	get_tree().reload_current_scene()
	
func generate_dungeon():
	# Initialize the starting room
	var start_room = instance_room()
	start_room.position = Vector2.ZERO  # Starting at (0, 0)
	add_child(start_room)
	
	used_positions[start_room.position] = start_room
	print("start room positiion: ")
	print(start_room.position)

	# Start placing connected rooms
	place_connected_rooms(start_room, 5)  # Adjust number of rooms


func place_player():
	# Create and position the player
	var player_instance = player.instantiate()
	player_instance.position = Vector2(50, 50)  #set position
	add_child(player_instance)
	
	
func place_enemies(count: int):
	for i in range(count):
		# Create and position the enemy
		var enemy_instance = enemy.instantiate()
		enemy_instance.position = Vector2(randi_range(0, 1500), randi_range(0, 1500))  #set position
		add_child(enemy_instance)

	
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
		if child is Marker2D and child.name.begins_with("D"):
			door_markers.append(child)
	print("Getting this room's doors:")
	print(room)
	print("door markers:")
	print(door_markers)
	return door_markers
