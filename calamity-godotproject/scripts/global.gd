extends Node
# PLAYER FLAGS
var player_current_attack = false
var player_can_use_stairs = false
var player_is_invincible = false
var restart_allowed = true
	
# PLAYER STATS
var player_coins = 0
var player_xp = 0
var floors = 1
var time_survived = 0.0
var kills = 0

# High scores
var best_xp = 0
var best_floors = 0
var best_time = 0
var best_kills = 0

func _process(delta) -> void:
	check_for_new_high_scores()

func check_for_new_high_scores():
	if player_xp > best_xp:
		#print("NEW BEST XP;;;;;;")
		#print(best_xp)
		best_xp = player_xp
		
	if floors > best_floors:
		#print("NEW BEST FLOORS;;;;;;")
		#print(best_floors)
		best_floors = floors
		
	if time_survived > best_time:
		#print("NEW BEST TIME;;;;;;")
		#print(best_time)
		best_time = time_survived
		
	if kills > best_kills:
		#print("NEW BEST KILLS;;;;;;")
		#print(best_kills)
		best_kills = kills
	
	
func reset_player_stats():
	player_xp = 0
	floors = 1
	time_survived = 0
	kills = 0

# PLAYER PERSISTENCE
var player_instance = null
var previous_floor = null
var restarting = false

func new_floor():
	floors += 1
	previous_floor.remove_child(player_instance)
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")
