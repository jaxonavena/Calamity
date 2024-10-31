extends CharacterBody2D

var speed = 45
var player_chase = false
var player = null

var health = 100
var player_in_attack_zone = false

func _physics_process(delta):
	deal_with_damage()
	
	if player_chase:
		position += (player.position - position )/speed
		$AnimatedSprite2D.play("slime run")
		
		if (player.position.x - position.x)< 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("slime idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	


func _on_detection_area_body_shape_exited(body):
	player = null
	player_chase = false


func enemy():
	pass


func _on_enemy_hitbox_body_shape_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true


func _on_enemy_hitbox_body_shape_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false

func deal_with_damage():
	if player_in_attack_zone and Global.player_current_attack == true:
		health = health - 20
		print("slime health - 20")
		if health <= 0:
			self.queue_free()
		
