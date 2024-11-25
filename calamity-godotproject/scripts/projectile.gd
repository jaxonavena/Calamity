'''
Name: projectile.gd
Description: File that allows projectiles to be used by enemies and players
Programmer: Pete Junge
Date: 11/13
Preconditions: None
Postconditions: Allows a projectile animation and instance to be used in other files
Faults: 
'''
extends CharacterBody2D # attachs the script to a Character node


@export var speed: float = 250 # defines speed for the projectile
@export var damage: int = 10 # defines how much damage it will do
@export var lifetime: float = 2.0 # defines how long the projectile will last
@export var effect_type: String = "default" # Options: "explosive", "piercing", "fast"
@export var pierce_count: int = 3 # Number of enemies it can pass through
@export var explosion_radius: float = 300 # defines the radius of the explosion
@onready var lifetime_timer = Timer.new() # sets a timer for how long it will last
@onready var fire_effect = $FireEffect # create a var that accesses a node FireEffect and assigns it to fire_effect

var direction: Vector2 # sets the direction as a 2D vector
var shooter: Node # sets shooter to see who will be shooting

func _ready():
	# Start moving the projectile
	set_physics_process(true)
	
	# Set up the timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true # says the timer will only trigger once
	lifetime_timer.connect("timeout", Callable(self, "on_lifetime_timeout")) # connects the timer to the on_lifetime_timeout function
	add_child(lifetime_timer) # add the timer to the curret object
	add_to_group("enemies") # add the object to "enemies"
	
func projectile():
	pass

# Callback when the lifetime of the projectile ends
func on_lifetime_timeout():
	#print("she gawn")
	queue_free()

func _process(delta):
	# Move the projectile in the direction it's facing
	position += direction * speed * delta
	

# Function to set the direction of the projectile
func set_direction(dir: Vector2, shooter_instance: Node):
	direction = dir.normalized() # normalize the direction
	shooter = shooter_instance # sets shooter to a Node instance
	#sfire_effect.emitting = true

func _on_area_2d_body_entered(body: Node2D) -> void: # function that triggers when a body enters a certain area
	#pass
	#if effect_type == "piercing":
		#handle_piercing(body)
	#elif effect_type == "explosive":
		#handle_explosive()
	#else:
	handle_default(body) # calls handle_default function
	#else: 
		#print("shooter dead asf")
		
func handle_default(body: Node2D): # handles the event when a projectile collides with a body
	if is_instance_valid(shooter): # sees if the shooter is still alive, then the shot works
		fire_effect.emitting = true
		if shooter.has_method("player") and body.has_method("enemy"): # if a player shoots an enemy, then the enemy takes damage
				body.deal_with_damage(true)
				#print("player hit a shot")
				queue_free() # removes the projectile from the map
		elif shooter.has_method("enemy") and body.has_method("player"): # if an enemy shoots a player, then the player takes damage
			body.enemy_attack(true)
			#print("gobs hit")
			queue_free() # removes the projectile from the map

func handle_piercing(body: Node2D): # function to handle a piercing projectile
	if shooter.has_method("player") and body.has_method("enemy"): # if a player pierces an enemy, then the enemy takes damage, and the pierce count decreases
				body.deal_with_damage(true)
				pierce_count -= 1
				if pierce_count <= 0:
					queue_free() # removes the projectile from the map if the pierce_count is zero or less
func handle_explosive(): # function to handle explosive projectiles
	#Unfinished bussiness
	print("Explosion triggered at position: ", global_position) # prints where the explosion happened at

	var explosion_area = Area2D.new() # sets the area that the explosion happened at
	var collision_shape = CollisionShape2D.new() # sets a shape for the explosion to happen inside of
	collision_shape.shape = CircleShape2D.new() # defines the shape of the explosion to happen in a circular area
	collision_shape.shape.radius = explosion_radius # sets the explosion radius
	explosion_area.add_child(collision_shape) # adds the shape to the explosion area
	#add_child(explosion_area)
	
	#defer
	call_deferred("add_child",explosion_area) # adds the sxplosion area after the current frame finishes
	explosion_area.call_deferred("set_monitoring", true) # sets the area to start looking for overlapping bodies
	await get_tree().process_frame # waits for the current frame to process before moving to the next step

	# Check all overlapping bodies
	var bodies = explosion_area.get_overlapping_bodies() # gets all the bodies that are in the explosion radius
	print("Radius: ", explosion_radius) # prints the explosion radius
	print("Bodies in explosion radius: ", bodies) # prints how many bodies are in the explosion
	for body in bodies: # loops through all the bodies and if they are enemies, it prints which enemy it is and does damge to the enemy
		if body.has_method("enemy"):
			print("Damaging enemy: ", body.name)
			body.deal_with_damage(true, damage)

	# Add visual and audio effects
	#if $Particles2D:
	#$Particles2D.emitting = true
	#if $AudioStreamPlayer:
	#$AudioStreamPlayer.play()

	# Clean up the projectile
	queue_free() # removes the explosive projectile from the map once it is over
	
func _on_wall_collision_body_entered(body) -> void: # function to handle if a projectile hits a wall
	 # Assuming layer 1 is for walls
	if is_instance_valid(shooter): # if the shooter is still alive, then continue executing
		if not(body.has_method("player")) and not(body.has_method("enemy")): # if the body that is hit is not a player or an enemy, then free the projectile and remove it from the map
			queue_free() 
