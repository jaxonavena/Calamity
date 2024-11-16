extends Control

# References to the labels
@onready var floors_cleared = $FloorsCleared
@onready var time_survived = $TimeSurvived
@onready var kills = $Kills
@onready var coins = $Coins
@onready var xp = $XP


func _ready():
	update_display()

func update_display():
	floors_cleared.text = "Floors: " + str(global_script.floors)
	time_survived.text = "Time: " + str(global_script.time_survived)
	kills.text = "Kills: " +str(global_script.kills)
	coins.text = "Coins: " + str(global_script.player_coins)
	xp.text = "XP: " + str(global_script.player_xp)
