'''
Name: main_menu.gd
Description: File that handles the menu that says to play or quit
Programmer: Jaxon Avena
Date: 11/3
Preconditions: None
Postconditions: Either playes the game or quits the game
Faults: 
'''
extends Control # attachs the scrip to a Control node that is usually used for UI elemnts (like buttons in this case)



func _on_play_pressed() -> void: # funtion that runs if the player selects the "play" button
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
	global_script.reset_player_stats() # resets the player's stats
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn") # changes the scene to generate a new dungeon
	

func _on_quit_pressed() -> void: # function that runs if the player selects the "quit" button
	get_tree().quit() # quits the game
