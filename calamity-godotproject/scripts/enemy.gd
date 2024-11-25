'''
Name: enemy.gd
Description: Create enemy that gets placed randomly and detects where the player is to go after them.
Programmer: Pete Junge
Date: 11/14
Preconditions: No inputs
Postconditions: Outputs a slime sprite randomly on the map
Faults: 
'''
extends CharacterBody2D # build in functionality for a 2D character

# set variables for movement
var speed = 50
var player_chase = false
var player = null

var coin_bag = preload("res://scenes/item_drop.tscn") # import the scene to drop a coin bag
var health_potion = preload("res://scenes/health_potion.tscn")
var health = 50 # set health variable
var player_in_attack_zone = false # set the enemy in the attack zone to false
@onready var hit_effect = $HitEffect # sets the variable that triggers a hit to reduce health
@onready var death_effect = $DeathEffect # sets the variable to trigger death when the health is gone

func _physics_process(delta): # declare the physics process function
	deal_with_damage() # declare the function that applies damage when an attack is made
	
	# if the player_chase var is true, then the enemy chases the player at a location near them that is randomly generated
	if player_chase:
		var salt = generate_random_offset(50, 50) 
		position += ((player.position + salt) - position )/speed 
		$AnimatedSprite2D.play("slime run") # play the animation that makes the slime enemy run
		
		if (player.position.x - position.x)< 0:
			$AnimatedSprite2D.flip_h = true # makes the slime character face left when the player us left of them
		else:
			$AnimatedSprite2D.flip_h = false # has the default false so the slime faces right
	else:
		$AnimatedSprite2D.play("slime idle") # plays the idle animation when the slime isn't chasing the player

	move_and_slide() # allows the CharacterBody2D to move with physics on surfaces
func generate_random_offset(x_range: float, y_range: float) -> Vector2: # function that randomly positions enemies on the map
	var random_x = randf_range(-x_range, x_range)
	var random_y = randf_range(-y_range, y_range)
	return Vector2(random_x, random_y) # returns the vector with the location
	
func _on_detection_area_body_entered(body): # function that determines when the enemy is within range to chase the player
	if body.has_method("player"):
		player = body
		player_chase = true
	#print("player chase")
	
func _on_detection_area_body_exited(body): # function that determines when the enemy is too far to chase the player
	if body.has_method("player"):
		player = null
		player_chase = false
	#print("stop player chase")
	
func enemy(): # empty function
	pass

func _on_enemy_hitbox_body_entered(body): # notifies that there is a player in the enemy's attack zone when a player enters the attack zone
	if body.has_method("player"):
		player_in_attack_zone = true
		#print("player in zone")
		

func _on_enemy_hitbox_body_exited(body): # notifies that the player is not in the hitbox when the player leaves the attack zone
	if body.has_method("player"):
		player_in_attack_zone = false
		#print("player left zone")

func deal_with_damage(shot = false): # function to handle if an emey takes damage
	if (player_in_attack_zone and global_script.player_current_attack == true) or shot: # if the enemy is close enough to the player, and the player attacks, then take damage with a little buffer time for the effect
		health = health - 10
		hit_effect.emitting = true
		await get_tree().create_timer(0.5).timeout
		hit_effect.emitting = false
		#print("slime health - 10")
		if health <= 0: # the enemy dies if the health reaches zero
			die()
		
func die(): # function for the enemy to die
	death_effect.emitting = true # activates the death animation
	await get_tree().create_timer(0.2).timeout # briefly buffers the execution
	drop_items() # drop the items that should come from the enemy
	update_player_xp() # increse the user's XP
	global_script.kills += 1 # increase kills for the user by one
	self.queue_free() # removes the enemy from the game

func drop_items():
	var num = randi_range(0, 10)
	if num > 7: # Chance to drop coins
		place_item(coin_bag)
	if num >= 5:
		place_item(health_potion)
		
func place_item(item):
	var item_instance = item.instantiate()
	item_instance.global_position = $Marker2D.global_position
	get_parent().add_child(item_instance)
	
func update_player_xp(): # function to update the player's XP
	var xp = randi_range(3, 20) # randomly generate an amount of XP to add and add it to the player
	global_script.player_xp = global_script.player_xp + xp
	#print("XP:")
	#print(global_script.player_xp)

func _on_projectile_timer_timeout() -> void:
	pass # Replace with function body.
