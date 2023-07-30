extends Control

var label_text = "BetterLuckNextTime"


func _ready():
	$VBoxContainer/HBoxContainer/TryAgainButton.grab_focus()
	$VBoxContainer/Label.text = label_text


func _on_try_again_button_pressed():
	get_tree().change_scene_to_file("res://scenes/stage.tscn")


func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
