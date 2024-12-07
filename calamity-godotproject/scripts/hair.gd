extends Node2D

@onready var hair_sprite = $Sprite2D

#KEYS
var hair_keys = []
var color_keys = []
var current_hair_index = 0
var current_color_index = 0

func _ready():
	setup_sprite_keys()
	update_sprite()
	
func setup_sprite_keys():
	hair_keys = global_script.hairs_collection.keys()
	
func update_sprite():
	var current_sprite = hair_keys[current_hair_index]
	if current_sprite == "none":
		hair_sprite.texture =null
		
	else:
		hair_sprite.texture = global_script.hairs_collection[current_sprite]
		hair_sprite.modulate = global_script.hair_color_options[current_color_index]
	
	global_script.selected_hair = current_sprite
	global_script.selected_hair_color =global_script.hair_color_options[current_color_index]
	


#Change Hair
func _on_collection_button_pressed() -> void:
	current_hair_index = (current_hair_index + 1) % hair_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % global_script.hair_color_options.size()
	update_sprite()
