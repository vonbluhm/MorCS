extends Control
@onready var settings = preload("res://settings.tres")
@onready var start_button = $VBoxContainer/StartButton


func _ready():
	start_button.grab_focus()
	var config = ConfigFile.new()
	var err = config.load("user://settings.ini")
	if err != OK:
		return
	if config.get_value("Player1", "character_set") == null:
		config.set_value("Player1", "character_set", 0)
	if config.get_value("Player1", "hide_codes") == null:
		config.set_value("Player1", "hide_codes", false)
	if config.get_value("Player1", "high_score") == null:
		config.set_value("Player1", "high_score", 0)
	if config.get_value("Player1", "beep_frequency") == null:
		config.set_value("Player1", "beep_frequency", 800)
	config.save("user://settings.ini")
	settings.dict_option = config.get_value("Player1", "character_set")
	settings.hide_codes = config.get_value("Player1", "hide_codes")
	settings.high_score = config.get_value("Player1", "high_score")
	settings.beep_frequency = config.get_value("Player1", "beep_frequency")


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/stage.tscn")


func _on_opitons_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
