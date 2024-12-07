'''
Name: main_menu.gd
Description: File that handles the main menu functionality: play, quit, and settings.
Programmer: Jaxon Avena
Date: 11/3
Preconditions: None
Postconditions: Either starts the game, opens the settings menu, or quits the game.
Faults: None
'''
extends Control  # Attach this script to a Control node, typically used for UI elements.

func _on_play_pressed() -> void:  # Function called when the "Play" button is pressed.
	global_script.reset_player_stats()  # Reset the player's stats.
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")  # Switch to the dungeon scene.

func _on_quit_pressed() -> void:  # Function called when the "Quit" button is pressed.
	get_tree().quit()  # Exit the game.

func _on_settings_pressed() -> void:  # Function called when the "Settings" button is pressed.
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")  # Switch to the settings menu scene.
