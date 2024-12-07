extends Control

#@export var game_manager : GameManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide() #hide pause menu
	#game_manager.connect("toggle_game_paused", on_game_manager_toggle_game_paused)


func _process(delta: float) -> void:
	pass
	
func on_game_manager_toggle_game_paused():
	if(global_script.game_paused):
		show()
	else:
		hide()
		
#func _input(event: InputEvent):
	#if Input.is_action_just_pressed("pause"):
		#if get_tree().paused:
			#get_tree().paused = false
