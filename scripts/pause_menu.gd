extends Control


@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var sprite = $Sprite2D
@onready var stage = get_parent().get_parent()


func _ready():
	var img = get_viewport().get_texture().get_image()
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.global_position.x = get_window().size.x * 0.5
	sprite.global_position.y = get_window().size.y * 0.5
	set_deferred("visible", false)


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		var img = get_viewport().get_texture().get_image()
		sprite.texture = ImageTexture.create_from_image(img)


func _on_resume_button_pressed():
	get_tree().paused = false
	set_deferred("visible", false)


func _on_quit_button_pressed():
	get_tree().paused = false
	stage.kill_all_symbols()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
