extends Node2D

@export var room_scenes: Array = []
var border_room = preload("res://scenes/border_room.tscn")
var player = preload("res://scenes/player.tscn")
var enemy = preload("res://scenes/enemy.tscn")
var used_positions = {}
var door_distance_offsets = {}
const NUM_ROOMS = 5
const ROOM_REMOVAL_PERCENTAGE = 15
var placed_rooms = []
var delay = false # Delay the generation/shrinkage of the dungeon to watch it happen live
const DELAY = 1.0

func _ready():
	generate_dungeon()
	place_player()
	place_enemies(10)
	
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

func get_spawn_location() -> Vector2:
	var salt = Vector2(randi_range(5, 160), randi_range(5, 160))
	return used_positions.keys()[randi_range(0, used_positions.size() - 1)] + salt
	
func place_player():
	# Create and position the player
	var player_instance = player.instantiate()
	player_instance.position = get_spawn_location()
	add_child(player_instance)
	
func place_enemies(count: int):
	for i in range(count):
		# Create and position the enemy
		var enemy_instance = enemy.instantiate()
		enemy_instance.position = get_spawn_location()
		add_child(enemy_instance)
	
func generate_dungeon():
	# Initialize the starting room
	var start_room = instance_room()
	start_room.global_position = Vector2(1000,800)
	add_child(start_room)
	placed_rooms.append(start_room)
	
	used_positions[start_room.global_position] = start_room
	calculate_door_distance_offsets(start_room)
	
	# Start placing connected rooms
	place_connected_rooms(start_room, NUM_ROOMS)  # Adjust number of rooms
	remove_some_rooms(ROOM_REMOVAL_PERCENTAGE) # Input the percentage of rooms you want to remove
	place_borders()

	
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
		
		var new_room = instance_room()
		var new_room_pos = current_room.global_position
		
		new_room.global_position = determine_new_room_pos(door, new_room_pos)
			
		if used_positions.has(new_room.global_position):
			continue  # Skip if there's already a connection here
				
		add_child(new_room)
		placed_rooms.append(new_room)
		used_positions[new_room.global_position] = new_room

		# UNCOMMENT THIS TO SEE THE DUNGEON GROW
		#if delay:
			#await wait_for(DELAY)
		
		# Recursively place more rooms
		place_connected_rooms(new_room, remaining_rooms - 1)

func remove_some_rooms(percentage: int):
	var initial_size = placed_rooms.size()
	while placed_rooms.size() > initial_size - ceil(initial_size * (percentage / 100.0)): # Remove designated percentage of rooms
		var random_index = randi_range(0, placed_rooms.size() - 1)
		var room = placed_rooms[random_index]
		
		if used_positions.has(room.global_position):
			used_positions.erase(room.global_position)
			
		room.queue_free()
		placed_rooms.remove_at(random_index) # pop
		
		# UNCOMMENT THIS TO SEE THE DUNGEON SHRINK
		if delay:
			await wait_for(DELAY)
		
	remove_non_adjacent_rooms() # clean inaccessible straggler rooms

func determine_new_room_pos(door: Node2D, current_pos: Vector2) -> Vector2:
	if door.name.begins_with("D1"):
		return current_pos - Vector2(0,door_distance_offsets["D3"].y)
	elif door.name.begins_with("D2"):
		return current_pos + Vector2(door_distance_offsets["D2"].x,0)
	elif door.name.begins_with("D3"):
		return current_pos + Vector2(0, door_distance_offsets["D3"].y)
	elif door.name.begins_with("D4"):
		return current_pos - Vector2(door_distance_offsets["D2"].x, 0)
	else:
		# Should never reach here if we properly name our doors
		print("ERROR in determine_new_room_pos()")
		return Vector2.ZERO
	
func get_door_markers(room: Node2D) -> Array:
	var door_markers = []
	for child in room.get_children():
		if child is Marker2D and child.name.begins_with("D"):
			door_markers.append(child)
	return door_markers
	
func remove_non_adjacent_rooms():
	for current_position in used_positions.keys():  # Iterate over the keys in used_positions
		# Iterate over all the other positions in the dictionary
		var flag = false
		for other_position in used_positions.keys():
			if current_position == other_position:
				continue  # Skip comparing the room with itself

			# Check if the room is adjacent by comparing the difference
			if is_adjacent(current_position, other_position):
				#print("Adjacent room found at:", other_position)
				flag = true
				break
		
		if !flag:
			var room = used_positions[current_position]
			used_positions.erase(room.global_position)
			room.queue_free()
			# Does not update placed_rooms... probably should
			
			# SEE THE DUNGEON SHRINK
			if delay:
				await wait_for(DELAY)

func is_adjacent(pos1: Vector2, pos2: Vector2) -> bool:
	# check if the two positions are adjacent up, down, left, or right
	var diff = pos1 - pos2
	return (abs(diff.x) == 160 and diff.y == 0) or (abs(diff.y) == 160 and diff.x == 0)

func wait_for(time: float):
	await get_tree().create_timer(time).timeout 
	
func place_borders():
	for current_position in used_positions.keys():  # Iterate over the keys in used_positions
		var adjacent_spaces = []
		adjacent_spaces.append(current_position + Vector2(0, 160)) #UP
		adjacent_spaces.append(current_position + Vector2(0, -160)) #DOWN
		adjacent_spaces.append(current_position + Vector2(-160, 0)) #LEFT
		adjacent_spaces.append(current_position + Vector2(160, 0)) #RIGHT
		
		for space in adjacent_spaces:
			if used_positions.has(space):
				continue
			else:
				print("Border time")
				var border = border_room.instantiate()
				border.global_position = space
				add_child(border)
				
				# SEE THE DUNGEON ADD BORDERS
				if delay:
					await wait_for(DELAY)
