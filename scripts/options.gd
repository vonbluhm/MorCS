extends Control

@onready var item_list = $VBoxContainer/HBoxContainer/ItemList
@onready var hide_codes_button = $VBoxContainer/HBoxContainer2/Button
@onready var freq_spinbox = $VBoxContainer/HBoxContainer3/SpinBox
var config = ConfigFile.new()


func _ready():
	config.load("user://settings.ini")
	item_list.grab_focus()
	item_list.select(Settings.dict_option)
	hide_codes_button.set_pressed_no_signal(Settings.hide_codes)
	freq_spinbox.value = Settings.beep_frequency


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_button_toggled(button_pressed):
	Settings.hide_codes = button_pressed
	save_config()


func _on_item_list_item_selected(index):
	Settings.dict_option = index
	save_config()
	

func _on_spin_box_value_changed(value):
	Settings.beep_frequency = value
	save_config()


func save_config():
	config.set_value("Player1", "character_set", Settings.dict_option)
	config.set_value("Player1", "hide_codes", Settings.hide_codes)
	config.set_value("Player1", "beep_frequency", Settings.beep_frequency)
	config.save("user://settings.ini")
