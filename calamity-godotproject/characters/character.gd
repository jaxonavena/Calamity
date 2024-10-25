extends CharacterBody2D
class_name Character

const FRICTION: float = 0.15
@export var acceleration: int = 40
@export var max_speed: int = 100

var mov_direction: Vector2 = Vector2.ZERO

onready var animated_sprite: AnimatedSprite2D = get_node("AnimatedSprite2D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * max_speed * _delta)
	move_and_slide()

func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * acceleration
	velocity = velocity.limit_length(max_speed)
