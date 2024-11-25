'''
Name: item_drop.gd
Description: File that triggers the player to gain coins when they walk over a coin bag
Programmer: Jaxon Avena
Date: 11/3
Preconditions: A player and coin bag on the map
Postconditions: Adds coins to the player
Faults: 
'''
extends StaticBody2D # extends a StaticBody2D which is a immovable body

func _on_detection_area_body_entered(body: Node2D) -> void: # function that is triggered when a Node2D enters the area of the object
	self.queue_free() # removes the coin bag from the map
	global_script.player_coins = global_script.player_coins + randi() % 5 + 1 # Adds 1-5 coins
