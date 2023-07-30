extends Control
@onready var settings = preload("res://settings.tres")


func _ready():
	$VBoxContainer/HBoxContainer/ItemList.grab_focus()
	$VBoxContainer/HBoxContainer2/Button.set_pressed_no_signal(settings.hide_codes)
	

func _on_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_button_toggled(button_pressed):
	settings.hide_codes = button_pressed
