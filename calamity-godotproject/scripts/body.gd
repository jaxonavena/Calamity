extends Node2D

@onready var body_sprite = $Sprite2D

#KEYS
var body_keys = []
var color_keys = []
var current_body_index = 0
var current_color_index = 0

func _ready():
	setup_sprite_keys()
	update_sprite()
	
func setup_sprite_keys():
	body_keys = global_script.bodies_collection.keys()
	
func update_sprite():
	var current_sprite = body_keys[current_body_index]
	body_sprite.texture = global_script.bodies_collection[current_sprite]
	body_sprite.modulate = global_script.body_color_options[current_color_index]
	
	global_script.selected_body = current_sprite
	global_script.selected_body_color =global_script.body_color_options[current_color_index]
	

#Change Body
func _on_collection_button_pressed() -> void:
	current_body_index = (current_body_index + 1) % body_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % global_script.body_color_options.size()
	update_sprite()
