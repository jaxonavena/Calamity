'''
Name: health_potion.gd
Description: File that triggers the player to gain hp when they walk over a health potion
Programmer: Jaxon Avena
Date: 11/25
Preconditions: A player and health potion on the map
Postconditions: Adds health to the player
Faults: 
'''

extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	self.queue_free()
	var player = get_node("/root/DungeonGenerator/Player")
	global_script.player_health += randi() % 5 + 1 # Adds 1-5 health
