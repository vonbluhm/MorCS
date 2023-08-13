extends Control
@onready var start_button = $VBoxContainer/StartButton
@onready var high_score_label = $HiScore/Label
var config = ConfigFile.new()

func _ready():
	start_button.grab_focus()
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
	Settings.dict_option = config.get_value("Player1", "character_set")
	Settings.hide_codes = config.get_value("Player1", "hide_codes")
	Settings.high_score = config.get_value("Player1", "high_score")
	Settings.beep_frequency = config.get_value("Player1", "beep_frequency")
	
	high_score_label.text = "High score: " + str(Settings.high_score)


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/stage.tscn")


func _on_opitons_button_pressed():
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_reset_button_pressed():
	config.set_value("Player1", "high_score", 0)
	config.save("user://settings.ini")
	Settings.high_score = config.get_value("Player1", "high_score")
	high_score_label.text = "High score: " + str(Settings.high_score)
