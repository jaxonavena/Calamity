extends Node2D

@export var speed: float = 400
@export var damage: int = 10
@export var lifetime: float = 2.0
@onready var lifetime_timer = Timer.new()

var direction: Vector2

func _ready():
	# Start moving the projectile
	set_physics_process(true)
	
	 # Set up the timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.connect("timeout", Callable(self, "on_lifetime_timeout"))
	add_child(lifetime_timer)
	lifetime_timer.start()
	#queue_free()

# Callback when the lifetime of the projectile ends
func on_lifetime_timeout():
	queue_free()  # Destroy the projectile after the lifetime ends

func _process(delta):
	# Move the projectile in the direction it's facing
	position += direction * speed * delta

# Function to set the direction of the projectile
func set_direction(dir: Vector2):
	direction = dir.normalized()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		print("It's an enemy")
		body.deal_with_damage(true)
		print(body.health)
		queue_free()  # Destroy the projectile after it hits something
