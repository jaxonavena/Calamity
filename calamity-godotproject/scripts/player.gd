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
const speed = 120	
var current_dir = "down"
var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var player_alive = true
var attack_in_progess = false
var projectile_hit = false
var attack_cooldown = false 

@onready var body = $Skeleton/Body
@onready var hair = $Skeleton/Hair
@onready var outfit = $Skeleton/Outfit
@onready var accessory = $Skeleton/Accessory
@onready var name_label = $Skeleton/Name
@onready var attack_area = $AttackArea2D
@onready var particles = $AttackParticle
@onready var cool_down_timer = $attack_timer

<<<<<<< HEAD
=======
const speed = 120	#speed of player movement
var current_dir = "down" #Starting player direction
var enemy_in_attack_range = false #Enemy hit range boolean
var enemy_attack_cooldown = true  # enemy attack cooldown for hits
var health = 250 #player health
var player_alive = true #boolean for if player is alive
var attack_in_progess = false  # if player is attacking 
var projectile_hit = false #if projectile hit 
var attack_cooldown = false

>>>>>>> fix stuff
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
	initialize_player()
	$Camera2D.enabled = false
	
	#attacks
	attack_area.monitoring = false
	attack_area.hide()
<<<<<<< HEAD

func _physics_process(delta):
	if !global_script.pause_game:
		player_movement(delta) # set movement funciton to run
		enemy_attack() # run the enemy attack function
		attack() #run the attack function
	
		if global_script.player_health <= 0: #check if player is alive
			player_alive = false #set to false if player dies
			#add death functionality here
			global_script.player_health = 0 #set global_script.player_health to 0 
			print("player is dead") #print 
			global_script.player_instance = null #erase player
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn") #change scene
=======
	
func _physics_process(delta):
	if !global_script.pause_game:
		player_movement()
		enemy_attack()
		attack()
	if health <= 0:
		player_alive = false
		health = 0
		print("player is dead")
		global_script.player_instance = null
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	elif Input.is_action_just_pressed("toggle_camera"): #check toggle
			$Camera2D.enabled = not $Camera2D.enabled # Press CMD+C to toggle the playe cam
>>>>>>> fix stuff

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
	elif global_script.no_path_to_stairs: #  there is no viable path to the stairs
		global_script.new_floor(0) # set new floor without incrementing the floorn ubmer
	else:
		play_animation(0) #play animation
		velocity.x = 0 #set x
		velocity.y = 0 #set y
		
	move_and_slide()
		
func restart_scene():
	var current_scene = get_tree().current_scene
	global_script.player_instance = null # does this do anything?
	global_script.reset_player_stats()
	get_tree().reload_current_scene()
	
func play_animation(movement):
	var dir = current_dir
	var anim = $AnimationPlayer
	if dir == "right":
		#anim.flip_h = false
		if movement == 1:
			anim.play("walk_right")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("idle_right")
	if dir == "left":
		#anim.flip_h = true
		if movement == 1:
			anim.play("walk_left")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("idle_left")
	if dir == "up":
		#anim.flip_h = false
		if movement == 1:
			anim.play("walk_up")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("idle_up")
	if dir == "down":
		#anim.flip_h = true
		if movement == 1:
			anim.play("walk_down")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("idle_down")

func player():
	# function for other classes to check if this is a player class
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = true
	elif body.has_method("projectile"):
		projectile_hit = true

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false
	elif body.has_method("projectile"):
		projectile_hit = false

func enemy_attack(shot = false):
	if (enemy_in_attack_range and enemy_attack_cooldown == true) or shot:
		if !global_script.player_is_invincible:
			global_script.player_health = global_script.player_health - 5;
		enemy_attack_cooldown = false
		$enemy_attackcooldown.start()

func _on_enemy_attackcooldown_timeout():
	enemy_attack_cooldown = true


func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		global_script.player_current_attack = true
		attack_in_progess = true
		attack_cooldown = true
		attack_area.monitoring = true
		attack_area.show()
		match current_dir:
			"right":
				particles.global_position = position + Vector2(20,0)
				particles.rotation_degrees = 0
			"left":
				particles.global_position = position + Vector2(-20, 0)
				particles.rotation_degrees = 180
			"up":
				particles.global_position = position + Vector2(0, -20)
				particles.rotation_degrees = -90
			"down":
				particles.global_position = position + Vector2(0, 20)
				particles.rotation_degrees = 90
				
		
		particles.emitting = true
		await get_tree().create_timer(0.5).timeout
		particles.emitting = false
		particles.global_position = attack_area.global_position
		
		cool_down_timer.start(0.5)
		
		
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
		
func initialize_player():
	body.texture = global_script.bodies_collection[global_script.selected_body]
	body.modulate = global_script.selected_body_color
	
	hair.texture = global_script.hairs_collection[global_script.selected_hair]
	hair.modulate = global_script.selected_hair_color
	
	outfit.texture = global_script.outfits_collection[global_script.selected_outfit]
	outfit.modulate = global_script.selected_outfit_color
	
	accessory.texture = global_script.accessory_collections[global_script.selected_accessory]
	accessory.modulate = global_script.selected_accessory_color
	
	name_label.text =  global_script.player_name
