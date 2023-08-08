extends Control


@onready var resume_button = $Panel/VBoxContainer/ResumeButton
@onready var sprite = $Sprite2D
@onready var blur = 0
@onready var stage = get_parent().get_parent()


func _ready():
	var img = get_viewport().get_texture().get_image()
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.global_position.x = get_window().size.x * 0.5
	sprite.global_position.y = get_window().size.y * 0.5
	set_deferred("visible", false)


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		var img = get_viewport().get_texture().get_image()
		sprite.texture = ImageTexture.create_from_image(img)
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		blur = 0
	elif blur < 4:
		blur += delta * 5
		if blur > 4:
			blur = 4
	$Sprite2D.material.set_shader_parameter("blur", blur)


func _on_resume_button_pressed():
	blur = 0
	get_tree().paused = false
	set_deferred("visible", false)


func _on_quit_button_pressed():
	get_tree().paused = false
	stage.kill_all_symbols()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
