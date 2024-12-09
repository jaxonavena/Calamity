extends CanvasLayer

var shop_scene = preload("res://scenes/Shop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("ready function")
	global_script.player_health = 250
	global_script.projectile_power = 10
	global_script.speed = 120

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_speed_button_pressed() -> void:
	if global_script.player_coins >=5:
		global_script.player_coins -= 5
		global_script.speed += 80


func _on_health_button_pressed() -> void:
	if global_script.player_coins >= 25:
		global_script.player_coins -= 25
		global_script.player_health += 50


func _on_damage_button_pressed() -> void:
	if global_script.player_coins >= 50:
		global_script.player_coins -= 50
		global_script.projectile_power += 10


func _on_close_pressed() -> void:
	print("close")
	queue_free()

func _input(event):
	print(event)
	if event is InputEventMouseButton:
		print("Mouse clicked")
