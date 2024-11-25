'''
Name: staircase.gd
Description: File that handles the player taking the stairs to get to another level
Programmer: Jaxon Avena
Date: 11/13
Preconditions: Stairs and a player on the map
Postconditions: Sends the player to another randomly generated dungeon
Faults: 
'''
extends Node2D # attachs the script to a Node2D, so the object is an area that the player can interact with

func _on_area_2d_body_entered(body: Node2D) -> void: # function that triggers when the player enters the area where the stairs are
	if body.has_method("player"): # sets the can_use_stairs var to true if the body that is there is a player
		global_script.player_can_use_stairs = true

func _on_area_2d_body_exited(body: Node2D) -> void: # function that triggers when the player leaves the area where the stairs are
	if body.has_method("player"): # sets the can_use_stiars var to false if the body is a player
		global_script.player_can_use_stairs = false
