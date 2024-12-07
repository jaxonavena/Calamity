'''
Name: global.gd
Description: File that sets player stats and creates high scores
Programmer: Jaxon Avena
Date: 11/14
Preconditions: Looks at current high scores
Postconditions: Outputs the player score for that round and the high scores if they are changed
Faults: 
'''
extends Node # the script is a Node class and set to behave like a basic node

var pause_game = false
# PLAYER FLAGS SET TO DEFAULT BOOLS
var player_current_attack = false
var player_can_use_stairs = false
var player_is_invincible = false
var restart_allowed = true
var no_path_to_stairs = false

# PLAYER STATS SET TO DEFAULT
var player_health = 250
var player_coins = 0
var player_xp = 0
var floors = 1
var time_survived = 0.0
var kills = 0

# High scores set to default
var best_xp = 0
var best_floors = 0
var best_time = 0
var best_kills = 0

func _process(delta) -> void: # function that runs the method to check for new high scores
	check_for_new_high_scores()

		

func check_for_new_high_scores(): # function that checks for new high scores
	if player_xp > best_xp: # sets best_xp to player_xp if it is a new high
		#print("NEW BEST XP;;;;;;")
		#print(best_xp)
		best_xp = player_xp
		
	if floors > best_floors: # sets best_floors to floors if it is a new high
		#print("NEW BEST FLOORS;;;;;;")
		#print(best_floors)
		best_floors = floors
		
	if time_survived > best_time: # sets best_time to time_survived if it is a new best
		#print("NEW BEST TIME;;;;;;")
		#print(best_time)
		best_time = time_survived
		
	if kills > best_kills: # sets best_kills to kills if it is a new best
		#print("NEW BEST KILLS;;;;;;")
		#print(best_kills)
		best_kills = kills
	
	
func reset_player_stats(): # function to set the player stats back to default
	player_xp = 0
	floors = 1
	time_survived = 0
	kills = 0

# PLAYER PERSISTENCE
var player_instance = null # variable that tracks if there is a player instance
var previous_floor = null # tracks which floor the player was on
var restarting = false

func new_floor(num = 1): # function that creats a new floor and keeps track of the amount that have been gone through
	floors += num # increases the floor count for the current game by 1
	previous_floor.remove_child(player_instance) # removes the player from the previous floor
	get_tree().reload_current_scene()
