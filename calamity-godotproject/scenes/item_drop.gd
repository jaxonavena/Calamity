extends StaticBody2D

func _on_detection_area_body_entered(body: Node2D) -> void:
	self.queue_free()
	global_script.player_coins = global_script.player_coins + 5
	print(global_script.player_coins)
