## Name of code artifact
##  pause menu
##Brief description of what the code does
##  A pause menu to implement a pausing ability mid game 
##Programmer’s name
## Pete Junge 
##Date the code was created
##  October 6thst 2024
##Dates the code was revised
## continuously being revised
##Brief description of each revision & author
## Pete junge added the whole scene  
##Preconditions
##Acceptable and unacceptable input values or types, and their meanings
#inputs: ESC key clicked to open and close the pause menu
##Postconditions
##Return values or types, and their meanings
## None
##Error and exception condition values or types that can occur, and their meanings
## none
##Side effects
## opens pause menu
extends Control

func _on_quit_pressed() -> void:
	print("quit")
	get_tree().quit()


func _on_resume_pressed() -> void:
	print("resume")
	global_script.pause_game = false
