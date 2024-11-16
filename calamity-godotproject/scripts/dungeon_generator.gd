extends Node2D

@export var room_scenes: Array = []
var border_room = preload("res://scenes/border_room.tscn")
var staircase = preload("res://scenes/staircase.tscn")
var player = preload("res://scenes/player.tscn")
var enemy = preload("res://scenes/enemy.tscn")
var enemyglobin = preload("res://scenes/enemyglobin.tscn")
var used_positions = {}
var door_distance_offsets = {}
const NUM_ROOMS = 5 #5
const ROOM_REMOVAL_PERCENTAGE = 15 #15
var placed_rooms = []
var delay = false # Delay the generation of the dungeon to watch it happen live, currently breaks everything if true
const DELAY = 1.0

# StatDisplay
var stat_display: Control
var floors_label
var time_survived_label
var kills_label
var coins_label
var xp_label

# DebugDisplay
var mouse_pos_label

# SPECIAL --------------------------------------------------------------------------------------------------------------
func _ready():
	generate_dungeon()
	print("PLAYER")
	place_player(global_script.player_instance)
	print("ENEMIES...")
	place_enemies(10)
	
	# UI
	find_stat_labels()
	find_debug_labels()
	update_stats()
	
func _process(delta):
	# cmd+R or ctrl+R press to restart the scene
	if Input.is_action_pressed("restart_scene"):
		restart_scene()
	
	global_script.time_survived += delta
	update_stats()
	update_mouse_pos()
	
func restart_scene():
	# Reload the current scene
	var current_scene = get_tree().current_scene
	global_script.player_instance = null
	global_script.reset_player_stats()
	get_tree().reload_current_scene()
	
# DUNGEON (build overall map) --------------------------------------------------------------------------------------------------------------
func generate_dungeon():
	var start_room = init_dungeon()
	
	place_connected_rooms(start_room, NUM_ROOMS) #recursive
	remove_some_rooms(ROOM_REMOVAL_PERCENTAGE) # input the percentage of rooms you want to remove
	place_borders() # walls off the dungeon
	print("STAIRS")
	place_staircase()
	
	global_script.previous_floor = get_tree().current_scene

func init_dungeon() -> Node2D:
	# Initialize the starting room
	var start_room = instance_room()
	start_room.global_position = Vector2(1000,800)
	add_child(start_room)
	placed_rooms.append(start_room)
	
	used_positions[start_room.global_position] = start_room
	calculate_door_distance_offsets(start_room)
	return start_room
	
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
		
		# SEE THE DUNGEON GROW
		# This breaks everything for some reason
		if delay:
			await wait_for(DELAY)
			
		# THis also might break everything, but might be ok
		var break_early = randi_range(1, 100)
		if break_early <= 10: #25% chance to not place four rooms around
			continue
			
		# Recursively place more rooms
		place_connected_rooms(new_room, remaining_rooms - 1)

func calculate_door_distance_offsets(current_room: Node2D):
	var room_pos = current_room.global_position
	var current_doors = get_door_markers(current_room)
	for door in current_doors:
		var pos = door.global_position
		door_distance_offsets[door.name] = pos - room_pos
		
func remove_some_rooms(percentage: int):
	var initial_size = placed_rooms.size()
	while placed_rooms.size() > initial_size - ceil(initial_size * (percentage / 100.0)): # Remove designated percentage of rooms
		var random_index = randi_range(0, placed_rooms.size() - 1)
		var room = placed_rooms[random_index]
		
		if used_positions.has(room.global_position):
			used_positions.erase(room.global_position)
			
		room.queue_free()
		placed_rooms.remove_at(random_index) # pop
		
		# SEE THE DUNGEON SHRINK
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
				var border = border_room.instantiate()
				border.global_position = space
				add_child(border)
				
				# SEE THE DUNGEON ADD BORDERS
				if delay:
					await wait_for(DELAY)
					
					
# SPAWNING (player, enemies, stairs) --------------------------------------------------------------------------------------------------------------
func salt(min: int, max: int) -> Vector2:
	return Vector2(randi_range(min, max), randi_range(min, max))
	
func tile_increment() -> Vector2:
	# Generate a random increment of 16 between 0 and 144
	# (0 to 9) * 16 gives increments from 0 to 144
	var x = randi() % 10 * 16
	var y = randi() % 10 * 16
	return Vector2(x,y)
	
func get_random_room_location() -> Vector2:
	return used_positions.keys()[randi_range(0, used_positions.size() - 1)]
	
#func get_spawn_location() -> Vector2: # Pick a spawn spot for characters
	#return get_random_room_location() + salt(5,160)
	
#func get_random_tile_location() -> Vector2:
	#return get_random_room_location() + tile_increment()
	
func is_spawnable_tile(spawn_location: Vector2) -> bool:
	# Actual -> Calc
	# (0,3) -> (2,3)
	# (6-8,2) -> (4,3)
	# (6-8,2) -> (4,2)
	# (2,1) -> (2,2)
	# (6-8,2) -> (2,2)
	# (3,1) -> (3,3)
	# (3,1) -> (4,3)
	# (2,1) -> (1,1)
	# (3,1) -> (2,1)
	var tile_map_layer = get_node("DungeonBase")
	var local_position = tile_map_layer.to_local(spawn_location)
	
	var cell = tile_map_layer.local_to_map(local_position)
	print("CELL")
	print(cell)
	
	var data = tile_map_layer.get_cell_tile_data(cell)
	print("DATA")
	print(data)
	
	if data:
		print("checking spawnable")
		print(!data.get_custom_data("not_spawnable"))
		print("\n")
		return !data.get_custom_data("not_spawnable") # I did not_spawnable instead of spawnable so we have to manually mark less tiles in the TileSet
	else:
		# We shouldn't hit this ever with valid global coords
		print("ERROR - Shouldn't be hitting this point. No TileData.")
		return true # avoids maximum recursion depth error
		
func is_spawnable_room(room_location: Vector2) -> bool:
	print("ROOM")
	print(used_positions[room_location])
	print("IS IN GROUP?")
	print(used_positions[room_location].is_in_group("spawnable_room"))
	return used_positions.has(room_location) and used_positions[room_location].is_in_group("spawnable_room")
	
func is_vector_in_range(vector: Vector2, min: int, max: int) -> bool:
	return vector.x >= min and vector.x <= max and vector.y >= min and vector.y <= max

var recursion_depth = 0
func get_valid_spawn_location(season: bool = false) -> Vector2:
	if recursion_depth > 100: 
		push_error("Recursion limit exceeded in get_valid_spawn_location")
		return Vector2.ZERO
	recursion_depth += 1
	print("Recursion depth:", recursion_depth)
	
	var room_location = get_random_room_location() # -> Vector 2
	print("GLOBAL SPAWN LOC:")
	print(room_location)
	if is_spawnable_room(room_location):
		print("It's spawnable")
		var salt = Vector2.ZERO
		var tile_increment = tile_increment()
		print("INCREMENT:")
		print(tile_increment)
		var tile_in_room = room_location + tile_increment
		print("TILE IN ROOM")
		print(tile_in_room)
		
		print("IN RANGE?")
		print(is_vector_in_range(tile_in_room, room_location.x + 15, room_location.y + 140))
		print("SEASON?")
		print(season)
		# add some margin so player/enemies hitboxes don't spawn barely in the wall of an adjacent room
		if is_vector_in_range(tile_in_room, room_location.x + 15, room_location.y + 140) and season:
			print("SALTING")
			salt = salt(0,16)
			print(salt)
			
		print("TOTAL SPAWN SPOT:")
		print(room_location + tile_increment() + salt)
		return room_location + tile_increment() + salt
	else:
		print("recurse")
		return get_valid_spawn_location()
		
func place_staircase():
	var tile_coord = get_valid_spawn_location()
	var stairs = staircase.instantiate()
	stairs.global_position = tile_coord
	add_child(stairs)
	
func place_player(player_instance: CharacterBody2D = null):
	print("\nPlayer stuff")
	var spawn_location = get_valid_spawn_location(true)
	if player_instance: # Player is moving on to the next floor
		player_instance.position = spawn_location
		add_child(player_instance)
	else: # Player is starting a new attempt
		player_instance = player.instantiate()
		player_instance.position = spawn_location
		add_child(player_instance)
		global_script.player_instance = player_instance
	
func place_enemies(count: int):
	for i in range(count):
		print("\nEnemy spawn")
		var slime_instance = enemy.instantiate()
		slime_instance.position = get_valid_spawn_location(true)
		add_child(slime_instance)
		
		var enemyglobin_instance = enemyglobin.instantiate()
		enemyglobin_instance.position = get_valid_spawn_location(true)
		add_child(enemyglobin_instance)

# UI --------------------------------------------------------------------------------------------------------------
func find_stat_labels():
	stat_display = get_node("CanvasLayer/StatDisplay") 
	floors_label = stat_display.get_node("FloorsCleared") 
	time_survived_label = stat_display.get_node("TimeSurvived") 
	kills_label = stat_display.get_node("Kills") 
	coins_label = stat_display.get_node("Coins") 
	xp_label = stat_display.get_node("XP")
				
func update_stats():
	floors_label.text = "Floors " + str(global_script.floors)
	time_survived_label.text = "Time: " + str(ceil(global_script.time_survived))
	kills_label.text = "Kills: " + str(global_script.kills)
	coins_label.text = "Coins: " + str(global_script.player_coins)
	xp_label.text = "XP: " + str(global_script.player_xp)
	
func find_debug_labels():
	mouse_pos_label = stat_display.get_node("MousePos")
	
func update_mouse_pos():
	mouse_pos_label.text = "Coords: " + str(get_global_mouse_position())
