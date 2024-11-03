extends CharacterBody2D

const speed = 100
var current_dir = "down"
var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_in_progess = false


func _ready():
	$AnimatedSprite2D.play("front_idle")

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	attack()
	if health <= 0:
		player_alive = false
		#add death functionality here
		health = 0
		$AnimatedSprite2D.play("death")
		print("player is dead")
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		
		
		
func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_animation(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_animation(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -speed
	elif Input.is_action_pressed("ui_end"):
		get_tree().quit()
		
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()


func play_animation(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_run")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_run")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("side_idle")
	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("backward_run")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("backward_idle")
	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("front_run")
		elif movement == 0:
			if attack_in_progess == false:
				anim.play("front_idle")

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = true


func _on_player_hitbox_body_shape_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false

func enemy_attack():
	if enemy_in_attack_range and enemy_attack_cooldown == true:
		health = health - 10;
		enemy_attack_cooldown = false
		$enemy_attackcooldown.start()
		print("player taken damage\n")


func _on_enemy_attackcooldown_timeout():
	enemy_attack_cooldown = true


func attack():
	var dir = current_dir
	if Input.is_action_just_pressed("attack"):
		global_script.player_current_attack = true
		attack_in_progess = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
			$attack_timer.start()
		elif dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
			$attack_timer.start()
		elif dir == "up":
			
			$AnimatedSprite2D.play("backward_attack")
			$attack_timer.start()
		elif dir == "down":
			
			$AnimatedSprite2D.play("front_attack")
			$attack_timer.start()
		
		
		
		


func _on_attack_timer_timeout():
	$attack_timer.stop()
	global_script.player_current_attack = false
	attack_in_progess = false
