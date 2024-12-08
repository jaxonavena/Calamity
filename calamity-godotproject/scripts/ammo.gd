'''
Name: ammo.gd
Description: File that triggers the player to gain ammo when they walk over ammo
Programmer: Jaxon Avena
Date: 12/7
Preconditions: A player and ammo on the map
Postconditions: Adds ammo to the player
Faults: 
'''

extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	self.queue_free()
	global_script.player_ammo += randi() % 10 + 3 # Adds 3-10 ammo
