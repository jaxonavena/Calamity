extends Control



func _on_play_pressed() -> void:
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")
	

func _on_quit_pressed() -> void:
	get_tree().quit()
