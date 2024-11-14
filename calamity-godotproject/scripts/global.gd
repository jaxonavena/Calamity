extends Node
# PLAYER FLAGS
var player_current_attack = false
var player_can_use_stairs = false

# PLAYER STATS
var player_coins = 0
var player_xp = 0
var floors_cleared = 0
var time_survived = 0.0
var kills = 0

func reset_player_stats():
	player_xp = 0
	floors_cleared = 0
	time_survived = 0
	kills = 0

# PLAYER PERSISTENCE
var player_instance = null
var previous_floor = null

func new_floor():
	floors_cleared += 1
	previous_floor.remove_child(player_instance)
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")
