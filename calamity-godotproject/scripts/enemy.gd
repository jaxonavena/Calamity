extends CharacterBody2D

var speed = 45
var player_chase = false
var player = null

var coin_bag = preload("res://scenes/item_drop.tscn")
var health = 30
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
	print("player chase")
	
func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	print("stop player chase")
	
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

func deal_with_damage():
	#if global_script.player_current_attack:
		#print("HYAH!")
	#if player_in_attack_zone:
		#print("attack da playa...")
		
	if player_in_attack_zone and global_script.player_current_attack == true:
		health = health - 10
		print("slime health - 10")
		if health <= 0:
			drop_items()
			self.queue_free()
		

func drop_items():
	var item_instance = coin_bag.instantiate()
	item_instance.global_position = $Marker2D.global_position
	get_parent().add_child(item_instance)
