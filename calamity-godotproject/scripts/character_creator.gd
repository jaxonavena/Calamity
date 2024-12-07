extends Node2D

#ref
@onready var name_box = $CreatorScreen/ColorRect/Details/TextEdit
var player_name = ""


# Player name
func _on_text_edit_text_changed() -> void:
	player_name = name_box.text

#change scene
func _on_confirm_button_pressed() -> void:
	global_script.player_name = player_name
	get_tree().change_scene_to_file("res://scenes/dungeon_generator.tscn")
