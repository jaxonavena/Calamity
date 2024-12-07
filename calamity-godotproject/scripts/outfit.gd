extends Node2D

@onready var outfit_sprite = $Sprite2D

#KEYS
var outfit_keys = []
var color_keys = []
var current_outfit_index = 0
var current_color_index = 0

func _ready():
	setup_sprite_keys()
	update_sprite()
	
func setup_sprite_keys():
	outfit_keys = global_script.outfits_collection.keys()
	
func update_sprite():
	var current_sprite = outfit_keys[current_outfit_index]
	outfit_sprite.texture = global_script.outfits_collection[current_sprite]
	outfit_sprite.modulate = global_script.color_options[current_color_index]
	
	global_script.selected_outfit = current_sprite
	global_script.selected_outfit_color =global_script.color_options[current_color_index]
	


#Change Outfit
func _on_collection_button_pressed() -> void:
	current_outfit_index = (current_outfit_index + 1) % outfit_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % global_script.color_options.size()
	update_sprite()
