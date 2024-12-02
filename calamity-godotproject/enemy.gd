extends CharacterBody2D

var speed = 50
var player_chase = false
var player = null

var coin_bag = preload("res://scenes/item_drop.tscn")
var health = 50
var player_in_attack_zone = false

func _physics_process(delta):
	deal_with_damage()
	
	if player_chase:
		var salt = generate_random_offset(50, 50)
		position += ((player.position + salt) - position )/speed 
		$AnimatedSprite2D.play("slime run")
		
		if (player.position.x - position.x)< 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("slime idle")

	move_and_slide()
func generate_random_offset(x_range: float, y_range: float) -> Vector2:
	var random_x = randf_range(-x_range, x_range)
	var random_y = randf_range(-y_range, y_range)
	return Vector2(random_x, random_y)
	
func _on_detection_area_body_entered(body):
	if body.has_method("player"):
		player = body
		player_chase = true
	#print("player chase")
	
func _on_detection_area_body_exited(body):
	if body.has_method("player"):
		player = null
		player_chase = false
	#print("stop player chase")
	
func enemy():
	pass

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true
		#print("player in zone")
		

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false
		#print("player left zone")

func deal_with_damage(shot = false):
	if (player_in_attack_zone and global_script.player_current_attack == true) or shot:
		health = health - 10
		#print("slime health - 10")
		if health <= 0:
			die()
		
func die():
	drop_items()
	update_player_xp()
	global_script.kills += 1
	self.queue_free()

func drop_items():
	var item_instance = coin_bag.instantiate()
	item_instance.global_position = $Marker2D.global_position
	get_parent().add_child(item_instance)
	
func update_player_xp():
	var xp = randi_range(3, 20)
	global_script.player_xp = global_script.player_xp + xp
	#print("XP:")
	#print(global_script.player_xp)

func _on_projectile_timer_timeout() -> void:
	pass # Replace with function body.
