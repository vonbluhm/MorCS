extends Control

@onready var settings = preload("res://settings.tres")
@onready var item_list = $VBoxContainer/HBoxContainer/ItemList
@onready var hide_codes_button = $VBoxContainer/HBoxContainer2/Button
@onready var freq_spinbox = $VBoxContainer/HBoxContainer3/SpinBox
var config = ConfigFile.new()


func _ready():
	config.load("user://settings.ini")
	item_list.grab_focus()
	item_list.select(settings.dict_option)
	hide_codes_button.set_pressed_no_signal(settings.hide_codes)
	freq_spinbox.value = settings.beep_frequency


func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_button_toggled(button_pressed):
	settings.hide_codes = button_pressed
	save_config()


func _on_item_list_item_selected(index):
	settings.dict_option = index
	save_config()
	

func _on_spin_box_value_changed(value):
	settings.beep_frequency = value
	save_config()


func save_config():
	config.set_value("Player1", "character_set", settings.dict_option)
	config.set_value("Player1", "hide_codes", settings.hide_codes)
	config.save("user://settings.ini")
