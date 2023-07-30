extends Control

func _ready():
	$VBoxContainer/ResumeButton.grab_focus()


func _on_resume_button_pressed():
	get_tree().paused = false
	queue_free()


func _on_quit_button_pressed():
	get_tree().paused = false
	get_parent().kill_all_symbols()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
