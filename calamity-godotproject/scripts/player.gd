extends CharacterBody2D

# Player stuff
const speed = 120	
var current_dir = "down"
var enemy_in_attack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_in_progess = false
var projectile_hit = false

# Ranged weapon stuff
@export var fire_rate: float = 0.5  # Time between shots
var projectile = preload("res://scenes/projectile.tscn")
var next_floor = preload("res://scenes/dungeon_generator.tscn")
var can_shoot = true  # Whether the player can shoot

func _process(delta):
	# Shoot projectile when the player presses the shoot button
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot_projectile()
		can_shoot = false
	
		# Wait for the next shot
		await wait_for(0.2)
	
		can_shoot = true

		
# Function to shoot a projectile
func shoot_projectile():
	var projectile_inst = projectile.instantiate()
	
	# In the player's shoot function
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	projectile_inst.set_direction(direction, self)
	
	# place the projectile down
	projectile_inst.position = $player_hitbox.global_position
	get_parent().add_child(projectile_inst)
	
	
func _ready():
	$Camera2D.enabled = false
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
		global_script.player_instance = null
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
	elif Input.is_action_just_pressed("toggle_camera"):
		$Camera2D.enabled = not $Camera2D.enabled # Press CMD+C to toggle the playe cam
		
func player_movement(delta):
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		current_dir = "right"
		play_animation(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		current_dir = "left"
		play_animation(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		current_dir = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = speed
	elif Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		current_dir = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -speed
	elif global_script.player_can_use_stairs and Input.is_key_pressed(KEY_E):
		global_script.new_floor()
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()

func restart_scene():
	# Reload the current scene
	var current_scene = get_tree().current_scene
	global_script.player_instance = null # does this do anything?
	global_script.reset_player_stats()
	get_tree().reload_current_scene()
	
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
	elif body.has_method("projectile"):
		projectile_hit = true


func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_attack_range = false
	elif body.has_method("projectile"):
		projectile_hit = false

func enemy_attack(shot = false):
	if (enemy_in_attack_range and enemy_attack_cooldown == true) or shot:
		health = health - 5;
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
		
		
func wait_for(time: float):
	await get_tree().create_timer(time).timeout 

func _on_attack_timer_timeout():
	$attack_timer.stop()
	global_script.player_current_attack = false
	attack_in_progess = false


func _on_projectile_timer_timeout():
	can_shoot = true
