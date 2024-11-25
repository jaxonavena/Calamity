'''
Name: stat_display.gd
Description: File that shows the stats for the game on teh screen
Programmer: Jaxon Avena
Date: 11/14
Preconditions: None
Postconditions: Sends the stats to the top left of the screen
Faults: 
'''
extends Control # attachs script to a node that is usually used for UI elemnts

# References to the labels to be displayed
@onready var floors_cleared = $FloorsCleared
@onready var time_survived = $TimeSurvived
@onready var kills = $Kills
@onready var coins = $Coins
@onready var xp = $XP


func _ready(): # functions that runs a function that updates the screen with the latest stats
	update_display()

func update_display(): # function that updates the text and values for the stat tracker
	floors_cleared.text = "Floors: " + str(global_script.floors) # Displays that number of floors that have been went through
	time_survived.text = "Time: " + str(global_script.time_survived) # displays how long the player has survived for
	kills.text = "Kills: " +str(global_script.kills) # displays how many kills the player has
	coins.text = "Coins: " + str(global_script.player_coins) # displays how many coins the player has collected
	xp.text = "XP: " + str(global_script.player_xp) # displays how much XP the player has gained
