'''
Name: enemyglobin.gd
Description: Create enemy that has ranged attacks to randomly generate on the map
Programmer: Pete Junge
Date: 11/15
Preconditions: No inputs
Postconditions: Outputs a goblin sprite randomly on the map that has ranged attacks
Faults: 
'''
extends CharacterBody2D # built in functionality for a 2D character

var speed = 45 # set var for how fast the goblin is
var player_chase = false # set chasing the player to false
var player = null # set pplayer to null
var shoot = null # set shoot to null
var can_shoot = true # allow the enemy to shoot
@export var fire_rate: float = 0.5  # Time between shots
var projectile = preload("res://scenes/projectile.tscn") # import the projectile scene
var coin_bag = preload("res://scenes/item_drop.tscn") # import the coin bag scene
var health = 30 # set goblin health to 30
var player_in_attack_zone = false # set enemy to no tbe in the player's attack zone
@onready var hit_effect = $HitEffect # set the variable that triggers a hit effect
@onready var death_effect = $DeathEffect # set the variable that triggers a death effect

func _physics_process(delta): # declare the physics process function
	if !global_script.pause_game:
		deal_with_damage() # declare the function that applies damage when an attack is made
		
		if player_chase: # if player_chase is true, then have the goblin chase after the player to a location rrandomly generated near the player
			var salt = generate_random_offset(50, 50)
			position += ((player.position + salt) - position )/speed 
			$AnimatedSprite2D.play("globin run") # play the goblin run animation
			
			if (player.position.x - position.x)< 0: # if the player is on the left of the goblin, then have the goblin face left
				$AnimatedSprite2D.flip_h = true
			else: # have the goblin face right if the player is on the right
				$AnimatedSprite2D.flip_h = false
			
			if can_shoot: # if can_shoot is true, then shoot at the player and start a timer before being able to shoot again
				shoot_projectile(player)
				can_shoot = false
				$projectile_timer.start()
		else: # else activate the idle goblin animation
			$AnimatedSprite2D.play("globin idle")
			
		move_and_slide() # allows the CharacterBody2D to move with physics on surfaces
# Function to shoot a projectile
func shoot_projectile(body): # creates an instance of a projectile and shoots it
	
	var projectile_inst = projectile.instantiate() # creates a projectile instance
	
	# In the player's shoot function
	var player_position = body.position # gets the player's position
	var direction = (player_position - global_position).normalized() # calculates the direction of the player and makes it a unit vector
	projectile_inst.set_direction(direction, self) # passes the direction into a set_direction method
	
	# place the projectile down
	projectile_inst.position = self.position # places the projectile instance at the goblin's location
	get_parent().add_child(projectile_inst) # adds the projectile as a child of the goblin in the scene
	


func generate_random_offset(x_range: float, y_range: float) -> Vector2: # function that randomly positions the goblin on the map
	var random_x = randf_range(-x_range, x_range)
	var random_y = randf_range(-y_range, y_range)
	return Vector2(random_x, random_y) # returns the vector with the position coordinates
	
func _on_detection_area_body_entered(body): # function to see if enemy has enetered a range near a body
	if body.has_method("player"): # if the body is a player then set player_chase to true
		player = body
		player_chase = true
	#print("player chase")
	
func _on_detection_area_body_exited(body): # function that says if you exit the area near the player then do not chase the player
	if body.has_method("player"):
		player = null
		player_chase = false
	#print("stop player chase")
	
func enemy():
	pass

func _on_enemy_hitbox_body_entered(body): # if the enemy enters the hitbox area of the player then set player_in_attack_zone to true
	if body.has_method("player"):
		player_in_attack_zone = true
		#print("player in zone")
		

func _on_enemy_hitbox_body_exited(body): # if the enemy exits the hitbox area of the player, then set player_in_attack_zone to false
	if body.has_method("player"):
		player_in_attack_zone = false
		#print("player left zone")

func deal_with_damage(shot = false): # function to handle if the enemy takes damage
	if (player_in_attack_zone and global_script.player_current_attack == true) or shot: # if the enemy is in the hitbox, and the player attacks or the enemy is shot, then remove 10 health and create a little buffer on the attacks
		health = health - 10
		$HitSound.play()
		hit_effect.emitting = true
		await get_tree().create_timer(0.5).timeout
		hit_effect.emitting = false
		if health <= 0: # if health is zero or less, then kill the goblin
			die()
		
func die(): # function to handle a goblin death
	death_effect.emitting = true # activate the death effect then wait a little to drop items and update player XP
	$DieEffect.play()
	await get_tree().create_timer(0.2).timeout
	drop_items()
	update_player_xp()
	self.queue_free() # free the goblin sprite from the map, so remove it
	
func drop_items():
	var num = randi_range(0, 10)
	if num > 2: # Chance to drop coins
		place_item(coin_bag)
		
func place_item(item):
	var item_instance = item.instantiate()
	item_instance.global_position = $Marker2D.global_position
	get_parent().add_child(item_instance)
	
func update_player_xp(): # function to update the player's XP
	var xp = randi_range(3, 20) # randommly generate an amount of XP
	global_script.player_xp = global_script.player_xp + xp # increase the player_XP by that random amount


func _on_projectile_timer_timeout() -> void: # once the timer expires, then the goblin is allowed to shoot again
	can_shoot = true
