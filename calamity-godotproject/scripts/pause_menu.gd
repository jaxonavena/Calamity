extends Control

func _on_quit_pressed() -> void:
	print("quit")
	get_tree().quit()


func _on_resume_pressed() -> void:
	print("resume")
	global_script.pause_game = false
