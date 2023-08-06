extends Control


@onready var resume_button = $VBoxContainer/ResumeButton


func _ready():
	set_deferred("visible", false)


func _on_resume_button_pressed():
	get_tree().paused = false
	set_deferred("visible", false)


func _on_quit_button_pressed():
	get_tree().paused = false
	get_parent().get_parent().kill_all_symbols()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
