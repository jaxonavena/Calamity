extends Control

func _ready():
	# Hides the pause menu when the game starts
	hide()
	# Connects the "pause" action to the _on_pause_toggle function
	InputMap.action_add_event("pause", InputEventKey.new())
	InputMap.action_get_events("pause")[0].keycode = KEY_ESCAPE
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("pause"):
		_on_pause_toggle()

func _on_pause_toggle():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	print("Pause toggled. Paused:", get_tree().paused)

func _on_resume_pressed() -> void:
	print("resume")
	_on_pause_toggle()

func _on_quit_pressed() -> void:
	print("quit")
	get_tree().quit()
