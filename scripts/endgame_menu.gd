extends Control

@onready var label = $VBoxContainer/Label
@onready var try_again_button = $VBoxContainer/HBoxContainer/TryAgainButton

func _ready():
	try_again_button.grab_focus()


func _on_try_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/stage.tscn")


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
