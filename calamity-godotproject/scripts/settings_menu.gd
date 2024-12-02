extends Control  # This script is attached to the Control node of the settings menu

# Save the volume to a persistent file
func save_volume_setting(value: float) -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "volume", value)  # Save volume value under "audio"
	config.save("user://settings.cfg")  # Save to user settings file

# Helper function to convert slider values (0-100) to decibels (-80 to 0)
func linear_to_db(value: float) -> float:
	if value == 0:
		return -80  # Minimum volume (mute)
	var db_value = -80 + (value / 100) * 80  # Scale 0-100 to -80 to 0 dB
	print("Slider Value:", value, " -> Decibels:", db_value)  # Debug log
	return db_value

# Load saved volume when settings menu opens
func _ready() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		var saved_volume = config.get_value("audio", "volume", 100)  # Default to 100
		$HSlider.value = saved_volume  # Set the slider to the saved volume
		AudioServer.set_bus_volume_db(0, linear_to_db(saved_volume))  # Apply saved volume
		$VolumeValue.text = str(int(saved_volume))  # Update the volume display label

# Called when the slider value changes
func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))  # Adjust the master audio bus volume
	$VolumeValue.text = str(int(value))  # Update the volume display label
	save_volume_setting(value)  # Save the current volume
