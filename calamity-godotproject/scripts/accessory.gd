extends Node2D

@onready var accessory_sprite = $Sprite2D

#KEYS
var accessory_keys = []
var color_keys = []
var current_accessory_index = 0
var current_color_index = 0

func _ready():
	setup_sprite_keys()
	update_sprite()
	
func setup_sprite_keys():
	accessory_keys = global_script.accessory_collections.keys()
	
func update_sprite():
	var current_sprite = accessory_keys[current_accessory_index]
	if current_sprite == "none":
		accessory_sprite.texture =null
		
	else:
		accessory_sprite.texture = global_script.accessory_collections[current_sprite]
		accessory_sprite.modulate = global_script.color_options[current_color_index]
	
	global_script.selected_accessory = current_sprite
	global_script.selected_accessory_color =global_script.color_options[current_color_index]
	


#Change Accessory
func _on_collection_button_pressed() -> void:
	current_accessory_index = (current_accessory_index + 1) % accessory_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % global_script.color_options.size()
	update_sprite()
