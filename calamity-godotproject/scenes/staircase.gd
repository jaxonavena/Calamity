extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		global_script.player_can_use_stairs = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		global_script.player_can_use_stairs = false
