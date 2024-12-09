'''
Name: dungeon_generator.gd
Description: This file randomly generates a new dungeon map with each new game or after a dungeon is completed
Programmer: Jaxon Avena
Date: 11/24
Preconditions: Not really any inputs
Postconditions: Returns a new map with a usable dungeon
Faults: 
'''
extends Node2D

# PRELOAD SCENES
@export var room_scenes: Array = []
var border_room = preload("res://scenes/border_room.tscn")
var staircase = preload("res://scenes/staircase.tscn")
var player = preload("res://scenes/player.tscn")
var enemy = preload("res://scenes/enemy.tscn")
var enemyglobin = preload("res://scenes/enemyglobin.tscn")
var shop = preload("res://scenes/Shop.tscn")


var used_positions = {} # Tracks locations of rooms on the map
var used_border_positions = {} # Tracks locations of border positions
var door_distance_offsets = {} # Tracks Vector2s of distances from each door in a room to the base location of the room
var player_spawn_room_location: Vector2 # Track which room the player spawns in
var stairs_can_spawn_in_start_room = false # Only true when there are no other spawnable rooms
var attempted_stair_rooms = [] # Tracks what rooms have been attempted to place a staircase in to avoid repeats
var stair_room_location: Vector2 # Track which room the stairs spawn in
var NUM_ROOMS = min(global_script.floors + 1, 5) # 5 is ideal with 15 removal
#var NUM_ROOMS = 5 # 5 is ideal with 15 removal
const ROOM_REMOVAL_PERCENTAGE = 15 #15 is ideal with 5 size
var placed_rooms = []
var delay = false # Delay the generation of the dungeon to watch it happen live, currently breaks everything if true
const DELAY = 0.2

# StatDisplay
var stat_display: Control
var floors_label
var time_survived_label
var kills_label
var coins_label
var xp_label
var health_label
var ammo_label
var dash_label

# DebugDisplay
var mouse_pos_label

# SPECIAL --------------------------------------------------------------------------------------------------------------
func _ready():
	global_script.no_path_to_stairs = false
	global_script.restarting = false # Currently restarting
	global_script.restart_allowed = true # Allowed to restart

	generate_dungeon() # Build the map
	place_player(global_script.player_instance) # Put the player on the map
	place_staircase() # Put the stairs far away from the player
	ensure_path_from_player_to_stairs()
	place_enemies(global_script.floors) # put the enemies on the map
	
	# UI
	find_stat_labels()
	find_debug_labels()
	update_stats()

func _process(delta):
	# cmd+R or ctrl+R press to restart the scene
	$CanvasLayer2/PauseMenu.visible = global_script.pause_game
	if Input.is_action_pressed("restart_scene") and global_script.restart_allowed:
		global_script.restarting = true
		restart_scene()
		
	if Input.is_action_just_pressed("pause"):
		global_script.pause_game = !global_script.pause_game
		
	if !global_script.pause_game:
		global_script.time_survived += delta #increment timer display
		update_stats()
		
	if global_script.restarting == false: # Avoids NULL PARAMETER ERROR when restarting
		update_mouse_pos()
	
func restart_scene():
	global_script.restart_allowed = false # Currently restarting, so don't allow another restart
	global_script.player_instance = null
	global_script.reset_player_stats()
		
	get_tree().reload_current_scene() # will reset restart_allowed = true
	
func wait_for(time: float): # sleep(n)
	await get_tree().create_timer(time).timeout 
	
# DUNGEON (build overall map) --------------------------------------------------------------------------------------------------------------
func generate_dungeon():
	# Builds the map
	#First places a starting room down, then recursively builds off of that before removing a percentage of the placed rooms
	# After rooms are removed, every empty edge is filled with a border room
	var start_room = init_dungeon()
	
	place_connected_rooms(start_room, NUM_ROOMS) #recursive
	remove_some_rooms(ROOM_REMOVAL_PERCENTAGE) # input the percentage of rooms you want to remove
	place_borders() # walls off the dungeon
	
	global_script.previous_floor = get_tree().current_scene

func init_dungeon() -> Node2D:
	# Initialize the starting room
	var start_room = instance_room()
	start_room.global_position = Vector2(1000,800)
	add_child(start_room)
	placed_rooms.append(start_room)
	
	used_positions[start_room.global_position] = start_room
	calculate_door_distance_offsets(start_room) # Since every room is the same dimensions, we only call this once
	return start_room
	
func instance_room() -> Node2D:
	# Choose a random room scene to instance
	var scene = room_scenes[randi() % room_scenes.size()]
	return scene.instantiate()


func place_connected_rooms(current_room: Node2D, remaining_rooms: int):
	# Recursively place rooms that are connected together to build the map
	
	if remaining_rooms <= 0: # Base case
		return

	var current_doors = get_door_markers(current_room) # Finds the Marker2D door nodes in the scene
	while current_doors.size() > 0: # Until we've iterated on all the available doors
		# pick a random side
		var random_index = randi_range(0, current_doors.size() - 1)
		var door = current_doors[random_index]
		current_doors.remove_at(random_index) # pop
		
		# make the new room
		var new_room = instance_room()
		var new_room_pos = current_room.global_position
		new_room.global_position = determine_new_room_pos(door, new_room_pos) # Find adjacent room spot depending on which side the door is on
			
		if used_positions.has(new_room.global_position): # unless we've already put something there
			continue
				
		add_child(new_room) # place the new room
		
		placed_rooms.append(new_room)
		used_positions[new_room.global_position] = new_room
		
		# SEE THE DUNGEON GROW
		# This breaks everything for some reason
		#if delay:
			#await wait_for(DELAY)
			
		# THis also might break everything, but might be ok
		var break_early = randi_range(1, 100)
		if break_early <= 10: #chance to not place four rooms around
			continue
			
		# Recursively place more rooms
		place_connected_rooms(new_room, remaining_rooms - 1)

func calculate_door_distance_offsets(current_room: Node2D):
	# Calculate distance from room_pos to each door in the room
	var room_pos = current_room.global_position
	var current_doors = get_door_markers(current_room)
	for door in current_doors:
		var pos = door.global_position
		door_distance_offsets[door.name] = pos - room_pos
		
func remove_some_rooms(percentage: int):
	# Delete the designated percentage of placed room
	var initial_size = placed_rooms.size()
	while placed_rooms.size() > initial_size - ceil(initial_size * (percentage / 100.0)): # Remove designated percentage of rooms
		var random_index = randi_range(0, placed_rooms.size() - 1)
		var room = placed_rooms[random_index]
		
		if used_positions.has(room.global_position):
			used_positions.erase(room.global_position)
			
		room.queue_free() # delete from scene
		placed_rooms.remove_at(random_index) # pop
		
		# SEE THE DUNGEON SHRINK
		if delay:
			await wait_for(DELAY)
		
	remove_non_adjacent_rooms() # clean inaccessible straggler rooms

func determine_new_room_pos(door: Node2D, current_pos: Vector2) -> Vector2:
	# Depending on which side the given door is on, place an adjacent room
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
	# Find all the Marker2D door nodes in a room scene
	var door_markers = []
	for child in room.get_children():
		if child is Marker2D and child.name.begins_with("D"):
			door_markers.append(child)
	return door_markers
	
func remove_non_adjacent_rooms():
	# After removing a perecentage of rooms randomly, there is sometimes some dangling rooms that have no connected edges, but are catty-corner
	# This function follows up to the previous removal function and finds and deletes any of these left over dangling room
	
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
			# There were no adjacent rooms found for the current room, so we delete it
			var room = used_positions[current_position]
			used_positions.erase(room.global_position)
			room.queue_free()
			# Does not update placed_rooms... probably should
			
			# SEE THE DUNGEON SHRINK
			if delay:
				await wait_for(DELAY)

func is_adjacent(pos1: Vector2, pos2: Vector2) -> bool:
	# check if the two room positions are adjacent up, down, left, or right
	var diff = pos1 - pos2
	return (abs(diff.x) == 160 and diff.y == 0) or (abs(diff.y) == 160 and diff.x == 0)
	
func place_borders():
	# Place the boundary border room scene down on all empty edges of the map
	for current_position in used_positions.keys():  # Iterate over the keys in used_positions
		var adjacent_spaces = []
		adjacent_spaces.append(current_position + Vector2(0, 160)) #UP
		adjacent_spaces.append(current_position + Vector2(0, -160)) #DOWN
		adjacent_spaces.append(current_position + Vector2(-160, 0)) #LEFT
		adjacent_spaces.append(current_position + Vector2(160, 0)) #RIGHT
		
		# Place the borders down
		for space in adjacent_spaces:
			if used_positions.has(space): # skip if position is taken
				continue
			else:
				var border = border_room.instantiate() # make
				used_border_positions[space] = border
				border.global_position = space
				add_child(border) # place
				
				# SEE THE DUNGEON ADD BORDERS
				if delay:
					await wait_for(DELAY)
					
func ensure_path_from_player_to_stairs():
	var path = find_path(player_spawn_room_location, stair_room_location)
	#print("PATH", path)
	if path == null:
		global_script.no_path_to_stairs = true # will regen a new_floor using the player instance
	
func find_path(current, goal, connected = [], visited = []):
	# Add the current position to the connected path
	connected.append(current)
	if current not in visited:
		visited.append(current) # Mark as visited

	# If the current position is the goal, return the path
	if current == goal:
		return connected

	# Directions to explore
	var directions = [
		current + Vector2(0, 160),
		current + Vector2(0, -160),
		current + Vector2(-160, 0),
		current + Vector2(160, 0)
	]

	# Explore neighbors
	for pos in directions:
		if pos in used_positions and pos not in visited:
			var result = find_path(pos, goal, connected, visited)
			if result != null:
				return result  # Return the path if found

	# If no path was found, return null
	return null
	
#func find_path(current, goal): #BFS version, no recursion
	#print("Finding path")
#
	## Initialize a queue with the starting point
	#var queue = []
	#queue.push_back([current])  # The queue stores paths, so we push the current position in a list
#
	## Create a set to keep track of visited nodes
	#var visited = []
#
	## Directions to explore
	#var directions = [
		#Vector2(0, 160),   # Up
		#Vector2(0, -160),  # Down
		#Vector2(-160, 0),  # Left
		#Vector2(160, 0)    # Right
	#]
#
	## While there are paths to explore
	#while queue.size() > 0:
		## Dequeue the first path from the queue
		#var path = queue.pop_front()
		## Get the last node in the current path
		#var current_pos = path[-1]
#
		## If we have already visited this node, skip it
		#if current_pos in visited:
			#continue
		#
		## Mark the current node as visited
		#visited.append(current_pos)
#
		## If the current node is the goal, return the path
		#if current_pos == goal:
			#return path
#
		## Explore neighbors
		#for direction in directions:
			#var neighbor = current_pos + direction
			#if neighbor in used_positions and neighbor not in visited:
				## Create a new path extending the current one
				#var new_path = path.duplicate()  # Duplicate the path to avoid mutating the original path
				#new_path.append(neighbor)
				#queue.push_back(new_path)  # Enqueue the new path
#
	## If no path was found, return null
	#return null


# SPAWNING (player, enemies, stairs) --------------------------------------------------------------------------------------------------------------
func salt(min: int, max: int) -> Vector2: # Return a Vector2 between some range, used to salt a room's tile coordinate and randomize further
	return Vector2(randi_range(min, max), randi_range(min, max))
	
func tile_increment() -> Vector2:
	# Generate a random increment of 16 between 0 and 144
	# (0 to 9) * 16 gives increments from 0 to 144
	var x = randi() % 10 * 16
	var y = randi() % 10 * 16
	return Vector2(x,y)
	
func get_random_room_location() -> Vector2: # i feel like you can guess
	return used_positions.keys()[randi_range(0, used_positions.size() - 1)]
	
#func get_spawn_location() -> Vector2: # Pick a spawn spot for characters
	#return get_random_room_location() + salt(5,160)
	
#func get_random_tile_location() -> Vector2:
	#return get_random_room_location() + tile_increment()
	
#func is_spawnable_tile(spawn_location: Vector2) -> bool:
	#var tile_map_layer = get_node("DungeonBase")
	#var local_position = tile_map_layer.to_local(spawn_location)
	#
	#var cell = tile_map_layer.local_to_map(local_position)
	#print("CELL")
	#print(cell)
	#
	#var data = tile_map_layer.get_cell_tile_data(cell)
	#print("DATA")
	#print(data)
	#
	#if data:
		#print("checking spawnable")
		#print(!data.get_custom_data("not_spawnable"))
		#print("\n")
		#return !data.get_custom_data("not_spawnable") # I did not_spawnable instead of spawnable so we have to manually mark less tiles in the TileSet
	#else:
		## We shouldn't hit this ever with valid global coords
		#print("ERROR - Shouldn't be hitting this point. No TileData.")
		#return true # avoids maximum recursion depth error
		
func is_spawnable_room(room_location: Vector2, is_player = false) -> bool:
	# Check if the room is spawnable
	if stairs_can_spawn_in_start_room: # Only occurs when the stairs have no other option
		return true
	if !is_player and room_location == player_spawn_room_location: # Nothing can spawn in the player's spawn room normally
		return false
	return used_positions.has(room_location) and used_positions[room_location].is_in_group("spawnable_room") # Return true if it's a valid room scene and is spawnable
	
func is_vector_in_range(vector: Vector2, min: int, max: int) -> bool: # take a guess
	return vector.x >= min and vector.x <= max and vector.y >= min and vector.y <= max

func get_valid_spawn_location(season: bool = false, is_player: bool = false, is_stairs: bool = false, i: int = 0, ) -> Vector2:
	# Recursively finds a spawnable location on the map
	
	i += 1 # TRACKING i IS NECESSARY FOR IT TO NOT EXPLODE ON AN INFINITE RECURSION ERROR. DO NOT ASK ME WHY THIS FIXED IT, I DONT KNOW
	#print(i)
	#print("GVSL")
	var room_location: Vector2
	if is_stairs:
		#print("\n\n\nstairs")
		room_location = get_furthest_spawnable_room(player_spawn_room_location) # -> Vector 2
		stair_room_location = room_location
		#print("Got room location")
	else:
		room_location = get_random_room_location()
	
	if is_spawnable_room(room_location, is_player):
		if is_stairs:
			#print("it is a spawnable room")
			stairs_can_spawn_in_start_room = false
			
		if is_player:
			player_spawn_room_location = room_location
			
		var salt = Vector2.ZERO
		var tile_increment = tile_increment()
		var tile_in_room = room_location + tile_increment
		
		# add some margin so player/enemies hitboxes don't spawn barely in the wall of an adjacent room
		if is_vector_in_range(tile_in_room, room_location.x + 15, room_location.y + 140) and season:
			salt = salt(0,16)
		
		#print("FINAL POSITION: ", room_location + tile_increment + salt)
		return room_location + tile_increment + salt
	else:
		return get_valid_spawn_location(i, season, is_player, is_stairs)
		
func rearrange_sibling_nodes(node1, node2):
	# Swaps node positions in the scene tree
	var parent = node1.get_parent()
	parent.move_child(node2, node1.get_index())  # Move Node2 before Node1 in scene tree
	
func get_furthest_spawnable_room(room_position: Vector2) -> Vector2:
	# Find the furthest spawnable room from a given room_positino
	var sorted_rooms = get_sorted_room_distances_from(room_position) # For all rooms in the map, sort their distances from the given room from least -> greatest
	var furthest_room_position = Vector2(-INF,INF) # non spawnable
	
	while !is_spawnable_room(furthest_room_position): # Until we get the furthest spawnable room
		#print("SORTED ROOMS SIZE", sorted_rooms.size())
		if sorted_rooms.size() > 0: # if we still have options
			furthest_room_position = sorted_rooms.pop_back().keys()[0] # grab the furthest room
		else: # When there are no other options except the start_room
			stairs_can_spawn_in_start_room = true
			#print("FURTHEST IS START ROOM", room_position)
			furthest_room_position = player_spawn_room_location
			
	#print("PLAYERSPAWN ROOM LOCATION", player_spawn_room_location)
	#print("RETURNING FURTHEST ROOM POS: ", furthest_room_position)
	return furthest_room_position
	
func get_sorted_room_distances_from(start_position: Vector2) -> Array:
	# Return a list of room positions distance from start_position from least->greatest
	var distances_hash: Dictionary # K:V = room_position: distance to start_position
	var sorted_rooms: Array # Sorted array of room positions via distance from start_position from least -> greatest
	var new_distance
	
	#print("USED POSITIONS SIZE:", used_positions.size())
	
	# Build distances hash
	for room_pos in used_positions.keys():
		new_distance = start_position.distance_to(room_pos)
		if room_pos != start_position:
			distances_hash[room_pos] = new_distance
	#print("\nDISTANCES HASH", distances_hash)
		
	# Bubble sort the distances from least -> greatest
	var ordered_distances = bubble_sort_vector2s_list(distances_hash.values())
	#print("\nORDERED DISTANCES ARRAY", ordered_distances)
	
	# Build sorted_rooms list
	var available_rooms = distances_hash.keys()
	for distance in ordered_distances:
		for room_pos in available_rooms:
			if distances_hash[room_pos] == distance:
				var index = available_rooms.find(room_pos)
				available_rooms.remove_at(index)
				sorted_rooms.append({room_pos: distance})
	#print("\nSORTED ROOMS", sorted_rooms)
	
	#var thing = []
	#for room in sorted_rooms:
		#thing.append(is_spawnable_room(room.keys()[0]))
	#print("THING: ", thing)
	return sorted_rooms
		
func bubble_sort_vector2s_list(distances: Array) -> Array:
	# Bubble sort Vector2s
	var n = distances.size()
	for i in range(n):
		var swapped = false
		for j in range(n-1-i):
			if distances[j] > distances[j + 1]:
				# SWAP
				var tmp = distances[j]
				distances[j] = distances[j + 1]
				distances[j + 1] = tmp
				swapped = true
		if not swapped:
			break
	return distances

func place_staircase():
	var tile_coord = get_valid_spawn_location(false, false, true) # find where to put it
	var stairs = staircase.instantiate()
	stairs.global_position = tile_coord
	add_child(stairs) # put it there
	
	# We need to know where the player's spawn room is to make sure enemies/stairs 
	# don't spawn in the same room. This requires us to spawn the stairs after the player, but if
	# we do that the player will be able to walk "under" the stairs sprite. So we rearrange the
	# order of the nodes in the tree, after the fact, so that everything is visually correct
	rearrange_sibling_nodes($Player, $Staircase)
	
func place_player(player_instance: CharacterBody2D = null):
	var spawn_location = get_valid_spawn_location(true, true) # find where to put it
	if player_instance: # Player is moving on to the next floor, save stats
		player_instance.global_position = spawn_location
		add_child(player_instance)
	else: # Player is starting a new attempt, restart fresh
		player_instance = player.instantiate()
		player_instance.global_position = spawn_location
		add_child(player_instance)
		global_script.player_instance = player_instance
	
func place_enemies(floors: int):
	# min: 75% of (2 * input), max: (2 * input)
	# Floor 1: min: 1.5 -> 1, max: 2, count: 
	# Floor 2: min: 3, max: 4
	var min = int(0.75 * 2 * floors)
	var max = int(4 * floors)
	var count = randi() % (max - min + 1) + min
	
	# Place them down
	for i in range(count):
		var slime_instance = enemy.instantiate()
		slime_instance.global_position = get_valid_spawn_location(true)
		add_child(slime_instance)
		
		var enemyglobin_instance = enemyglobin.instantiate()
		enemyglobin_instance.global_position = get_valid_spawn_location(true)
		add_child(enemyglobin_instance)

# UI --------------------------------------------------------------------------------------------------------------
func find_stat_labels():
	# Grab on to the stat labels on the UI
	stat_display = get_node("CanvasLayer/StatDisplay") 
	floors_label = stat_display.get_node("FloorsCleared") 
	time_survived_label = stat_display.get_node("TimeSurvived") 
	kills_label = stat_display.get_node("Kills") 
	coins_label = stat_display.get_node("Coins") 
	xp_label = stat_display.get_node("XP")
	health_label = stat_display.get_node("Health")
	ammo_label = stat_display.get_node("Ammo")
	dash_label = stat_display.get_node("DashAbility")
				
func update_stats():
	# Update the stat labels on the UI
	floors_label.text = "Floors " + str(global_script.floors)
	time_survived_label.text = "Time: " + str(ceil(global_script.time_survived))
	kills_label.text = "Kills: " + str(global_script.kills)
	coins_label.text = "Coins: " + str(global_script.player_coins)
	xp_label.text = "XP: " + str(global_script.player_xp)
	health_label.text = "HP: "  + ("|".repeat(global_script.player_health / 10))
	ammo_label.text = "Ammo: " + str(global_script.player_ammo)
	dash_label.text = "Dash Available: " + str(global_script.dash_available)
	
func find_debug_labels():
	# Grab on to the debug labels on the UI
	mouse_pos_label = stat_display.get_node("MousePos")
	
func update_mouse_pos():
	# Update the mouse position display
	mouse_pos_label.text = "Coords: " + str(get_global_mouse_position())
