extends Node

var player_current_attack = false
var player_coins = 0
var player_xp = 0
var player_can_use_stairs = false
var player_instance = null
var previous_floor = null

func new_floor():
	previous_floor.remove_child(player_instance)
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")
