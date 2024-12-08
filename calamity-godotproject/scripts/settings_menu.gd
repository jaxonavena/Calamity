extends Control  # This script is attached to the Control node of the settings menu

var max_db: float = 0  # Variable to store the game's maximum volume (initial volume)

# Save the slider value (volume) to a persistent file
func save_volume_setting(value: float) -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "volume", value)  # Save slider value under "audio"
	config.save("user://settings.cfg")  # Save to user settings file
	print("Saved slider value:", value)  # Debug

# Convert slider value (0-100) to decibels using global math functions
func slider_to_db(value: float) -> float:
	if value == 0:
		return -80  # Minimum volume (mute)
	# Convert 0-100 to a linear scale (0.0 - 1.0), then to decibels
	var db = linear_to_db(value / 100.0)
	print("Slider to DB: value =", value, "db =", db)  # Debug
	return db

# Convert decibels back to slider value (0-100) using global math functions
func db_to_slider(db: float) -> float:
	if db <= -80:
		return 0  # Mute
	# Convert decibels to a linear scale, then scale to 0-100
	var slider_value = db_to_linear(db) * 100.0
	print("DB to Slider: db =", db, "slider value =", slider_value)  # Debug
	return slider_value

# Initialize the settings menu
func _ready() -> void:
	# Get the current audio bus volume as the max_db (initial game's volume)
	max_db = AudioServer.get_bus_volume_db(0)
	print("Max DB (initial volume):", max_db)  # Debug

	# Check if a saved slider value exists
	var saved_slider_value: float = 100  # Default to 100 (max volume)
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		saved_slider_value = config.get_value("audio", "volume", 100)

	# Set the slider to the saved value and update volume
	$HSlider.value = saved_slider_value
	$VolumeValue.text = str(int(saved_slider_value))
	AudioServer.set_bus_volume_db(0, slider_to_db(saved_slider_value))  # Apply volume

# Called when the slider value changes
func _on_h_slider_value_changed(value: float) -> void:
	# Adjust the audio bus volume based on the slider value
	print("Slider Changed: value =", value)  # Debug
	AudioServer.set_bus_volume_db(0, slider_to_db(value))
	$VolumeValue.text = str(int(value))  # Update the slider display
	save_volume_setting(value)  # Save the current slider value

# Go back to the main menu
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
