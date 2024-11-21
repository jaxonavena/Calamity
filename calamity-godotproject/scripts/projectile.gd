extends CharacterBody2D


@export var speed: float = 250
@export var damage: int = 10
@export var lifetime: float = 2.0
@export var effect_type: String = "default" # Options: "explosive", "piercing", "fast"
@export var pierce_count: int = 3 # Number of enemies it can pass through
@export var explosion_radius: float = 300
@onready var lifetime_timer = Timer.new() 
@onready var fire_effect = $FireEffect

var direction: Vector2
var shooter: Node

func _ready():
	# Start moving the projectile
	set_physics_process(true)
	
	# Set up the timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.connect("timeout", Callable(self, "on_lifetime_timeout"))
	add_child(lifetime_timer)
	add_to_group("enemies")
	
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
	direction = dir.normalized()
	shooter = shooter_instance
	#sfire_effect.emitting = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	#pass
	#if effect_type == "piercing":
		#handle_piercing(body)
	#elif effect_type == "explosive":
		#handle_explosive()
	#else:
	handle_default(body)
	#else: 
		#print("shooter dead asf")
		
func handle_default(body: Node2D):
	if is_instance_valid(shooter):
		fire_effect.emitting = true
		if shooter.has_method("player") and body.has_method("enemy"):
				body.deal_with_damage(true)
				#print("player hit a shot")
				queue_free()
		elif shooter.has_method("enemy") and body.has_method("player"):
			body.enemy_attack(true)
			#print("gobs hit")
			queue_free()

func handle_piercing(body: Node2D):
	if shooter.has_method("player") and body.has_method("enemy"):
				body.deal_with_damage(true)
				pierce_count -= 1
				if pierce_count <= 0:
					queue_free()
func handle_explosive():
	#Unfinished bussiness
	print("Explosion triggered at position: ", global_position)

	var explosion_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = explosion_radius
	explosion_area.add_child(collision_shape)
	#add_child(explosion_area)
	
	#defer
	call_deferred("add_child",explosion_area)
	explosion_area.call_deferred("set_monitoring", true)
	await get_tree().process_frame

	# Check all overlapping bodies
	var bodies = explosion_area.get_overlapping_bodies()
	print("Radius: ", explosion_radius)
	print("Bodies in explosion radius: ", bodies)
	for body in bodies:
		if body.has_method("enemy"):
			print("Damaging enemy: ", body.name)
			body.deal_with_damage(true, damage)

	# Add visual and audio effects
	#if $Particles2D:
	#$Particles2D.emitting = true
	#if $AudioStreamPlayer:
	#$AudioStreamPlayer.play()

	# Clean up the projectile
	queue_free()
	
func _on_wall_collision_body_entered(body) -> void:
	 # Assuming layer 1 is for walls
	if is_instance_valid(shooter):
		if not(body.has_method("player")) and not(body.has_method("enemy")):
			queue_free()
