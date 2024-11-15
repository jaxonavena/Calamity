extends Node2D

@export var speed: float = 250
@export var damage: int = 10
@export var lifetime: float = 2.0
@onready var lifetime_timer = Timer.new()

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	#pass
	if is_instance_valid(shooter):
		if shooter.has_method("player") and body.has_method("enemy"):
				body.deal_with_damage(true)
				#print("player hit a shot")
				queue_free()
		elif shooter.has_method("enemy") and body.has_method("player"):
			body.enemy_attack(true)
			#print("gobs hit")
			queue_free()
	#else: 
		#print("shooter dead asf")
