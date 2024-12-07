extends CharacterBody2D
# Prologue comment
## Name of code artifact
##  Player class
##Brief description of what the code does
##  Creates a player class that can take in input from the user to control, attack, and play the game and deals with damage done by enemies 
##Programmer’s name
## Pete Junge and Jaxon Avena
##Date the code was created
##  October 31st 2024
##Dates the code was revised
## continuously being revised
##Brief description of each revision & author
## Pete junge added player, movement, inputs, attacks, 
## Jaxon added shooting
##Preconditions
##Acceptable and unacceptable input values or types, and their meanings
#inputs: arrows: movement, space: melee, mouse: aim , right click: shoot, E: enter new level 
##Postconditions
##Return values or types, and their meanings
## None
##Error and exception condition values or types that can occur, and their meanings
## none
##Side effects
## enemy objects being destroyed


# Player stuff
const speed = 120	#speed of player movement
var current_dir = "down" #Starting player direction
var enemy_in_attack_range = false #Enemy hit range boolean
var enemy_attack_cooldown = true  # enemy attack cooldown for hits
var health = 250 #player health
var player_alive = true #boolean for if player is alive
var attack_in_progess = false  # if player is attacking 
var projectile_hit = false #if projectile hit 

# Ranged weapon stuff
@export var fire_rate: float = 0.5  # Time between shots
var projectile = preload("res://scenes/projectile.tscn") #preloading the projectile scene so it can be used
var next_floor = preload("res://scenes/dungeon_generator.tscn")  #preload the next floor 
var can_shoot = true  # Whether the player can shoot
var weapons = [preload("res://scenes/projectile.tscn") , preload("res://scenes/projectile_piercing.tscn"), preload("res://scenes/projectile_fast.tscn"), preload("res://scenes/projectile_explosive.tscn")] #preloading all weapons
var current_weapon_index = 0 # index for weapons
var projectile1 = weapons[current_weapon_index] #default weapon
 

func _process(delta):
	# Shoot projectile when the player presses the shoot button
	if !global_script.pause_game:
		if Input.is_action_pressed("shoot") and can_shoot:
			shoot_projectile() #run shoot function
			can_shoot = false #set ability to shoot to false for cooldown
			# Wait for the next shot
			await wait_for(0.2) 
		
			can_shoot = true #set it back to true after cooldown

		
# Function to shoot a projectile
func shoot_projectile():
	var projectile_inst = projectile1.instantiate() #create instance of projectile
	
	# In the player's shoot function
	var mouse_position = get_global_mouse_position() # get mouse direction
	var direction = (mouse_position - global_position).normalized() #set direction variable
	projectile_inst.set_direction(direction, self) # set direction for instance
	
	# place the projectile down
	projectile_inst.position = $player_hitbox.global_position
	get_parent().add_child(projectile_inst) # add instance as a child
	
	
func _ready():
	$Camera2D.enabled = false #set camera
	$AnimatedSprite2D.play("front_idle")  #set idle animation

func _physics_process(delta):
	if !global_script.pause_game:
		player_movement(delta) # set movement funciton to run
		enemy_attack() # run the enemy attack function
		attack() #run the attack function
	
		if health <= 0: #check if player is alive
			player_alive = false #set to false if player dies
			#add death functionality here
			health = 0 #set health to 0 
			$AnimatedSprite2D.play("death") #play death animation
			print("player is dead") #print 
			global_script.player_instance = null #erase player
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn") #change scene
	
		elif Input.is_action_just_pressed("toggle_camera"): #check toggle
			$Camera2D.enabled = not $Camera2D.enabled # Press CMD+C to toggle the playe cam
		
func player_movement(delta): # movement function
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D): #right arrow pressed
		current_dir = "right" #set direction
		play_animation(1) #play animation
		velocity.x = speed #set speed
		velocity.y = 0 # set y
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A): # left direction pressed
		current_dir = "left" #set direction
		play_animation(1) #play animation
		velocity.x = -speed #set speed
		velocity.y = 0 #set y 
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):  #down direction is pressed
		current_dir = "down" #set direction
		play_animation(1) #play direction
		velocity.x = 0  #set x
		velocity.y = speed #set y
	elif Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W): # up direction is pressed
		current_dir = "up" #set direction
		play_animation(1) #play animation
		velocity.x = 0 #set x
		velocity.y = -speed #set y 
	elif global_script.player_can_use_stairs and Input.is_key_pressed(KEY_E): #E is pressed
		global_script.new_floor() #set new floor
	else:
		play_animation(0) #play animation
		velocity.x = 0 #set x
		velocity.y = 0 #set y
		
	move_and_slide() #deal with movement and collsiions 

func restart_scene():
	# Reload the current scene
	var current_scene = get_tree().current_scene #set scene
	global_script.player_instance = null # does this do anything?
	global_script.reset_player_stats() #reset stats
	get_tree().reload_current_scene() #load current scene
	
func play_animation(movement): # animation function
	var dir = current_dir # set direction
	var anim = $AnimatedSprite2D #grab sprite
	if dir == "right": #if right 
		anim.flip_h = false #dont flip sprite
		if movement == 1: # if movement
			anim.play("side_run") #play animation
		elif movement == 0: #if no movement
			if attack_in_progess == false: #if not attack
				anim.play("side_idle") # play animation
	if dir == "left": #if direction is left
		anim.flip_h = true #flip sprite to face left
		if movement == 1: # if movement
			anim.play("side_run") #play animation 
		elif movement == 0: #if no movement
			if attack_in_progess == false: #if not attack
				anim.play("side_idle") # play animation
	if dir == "up": #if direction is up 
		anim.flip_h = false #dont flip sprite
		if movement == 1: # if movement
			anim.play("backward_run") #play animation
		elif movement == 0: #if no movement
			if attack_in_progess == false: #if not attack
				anim.play("backward_idle") #play animation
	if dir == "down": #if direction is down
		anim.flip_h = true #flip sprite
		if movement == 1: #if movement
			anim.play("front_run") #play animation
		elif movement == 0: #if no movement
			if attack_in_progess == false: # if no attack 
				anim.play("front_idle") #play animation 

func player():
	# function for other classes to check if this is a player class
	pass

func _on_player_hitbox_body_entered(body):
	#function to check if a enemy is in hitbox range
	if body.has_method("enemy"): #check if it is a enemy
		enemy_in_attack_range = true # set enemy in range to true
	elif body.has_method("projectile"): #check if it is a projectile
		projectile_hit = true # projectile hit 


func _on_player_hitbox_body_exited(body): #function to update if object leaves hitbox
	if body.has_method("enemy"): #check if it is a enemy
		enemy_in_attack_range = false #set enemy in attack to false
	elif body.has_method("projectile"): # check if it is a projectile
		projectile_hit = false #set projectile hit to false

func enemy_attack(shot = false): #deal with enemy attacks
	if (enemy_in_attack_range and enemy_attack_cooldown == true) or shot: #if it is a enemy attack
		if !global_script.player_is_invincible: #check if invincible 
			health = health - 5; #decrease health
		enemy_attack_cooldown = false #set cooldown to false
		$enemy_attackcooldown.start() #start cooldown
		#print("player taken damage\n")


func _on_enemy_attackcooldown_timeout(): #function for cooldown
	enemy_attack_cooldown = true #set to true


func attack(): #attack fucntion
	var dir = current_dir #set direction
	if Input.is_action_just_pressed("attack"): #check for input
		global_script.player_current_attack = true # set to true
		attack_in_progess = true #set attack in progess to true
		if dir == "right": #if direction is right
			$AnimatedSprite2D.flip_h = false #dont flip sprite
			$AnimatedSprite2D.play("side_attack") #play animation
			$attack_timer.start() #start timer
		elif dir == "left": #if direction is left
			$AnimatedSprite2D.flip_h = true #flip sprite 
			$AnimatedSprite2D.play("side_attack") #play animation 
			$attack_timer.start() #start timer
		elif dir == "up": #if direction is up
			$AnimatedSprite2D.play("backward_attack") #play animation
			$attack_timer.start() #start timer
		elif dir == "down": #if direction is down
			$AnimatedSprite2D.play("front_attack") #play animation
			$attack_timer.start() #start timer
		
		
func wait_for(time: float): #set a timer
	await get_tree().create_timer(time).timeout #wait for timer 

func _on_attack_timer_timeout(): #attack timer 
	$attack_timer.stop() #stop the timer
	global_script.player_current_attack = false #set player attack to false
	attack_in_progess = false #set progess to false


func _on_projectile_timer_timeout(): #projectile timer
	can_shoot = true #set to true
	
func _input(event): #check for inputs 
	if event.is_action_pressed("switch_weapon"): #if switch weapon buttons are pressed
		print("Switch weapon triggered") #print
		current_weapon_index = (current_weapon_index + 1) % weapons.size() #set index 
		projectile1 = weapons[current_weapon_index] #set weapon
		print("Switched to weapon", current_weapon_index) #switch
		#$WeaponLabel.text = "Weapon: " + str(current_weapon_index) 
		#$WeaponSwitchSound.play()
