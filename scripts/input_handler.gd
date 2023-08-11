extends Node2D

var output = "" 
const DOT = "."
const DASH = "-"
@onready var stage = get_parent()
@onready var label = $Label
@onready var dot_dash = $DotDashTimer
@onready var end_of_symbol = $SymbolSpaceTimer
@onready var generator_scene = preload("res://scenes/generator.tscn")


func _process(_delta):
	if Input.is_action_just_pressed("button_pressed"):
		dot_dash.start()
		end_of_symbol.stop()
		var instance = generator_scene.instantiate()
		instance.add_to_group("generator")
		add_child(instance)
	if Input.is_action_just_released("button_pressed"):
		if not dot_dash.is_stopped():
			dot_dash.stop()
			output += DOT
			label.text = output
		end_of_symbol.start()
		for child in get_children():
			if child.is_in_group("generator"):
				child.queue_free()


func _on_dot_dash_timer_timeout():
	output += DASH
	label.text = output


func _on_symbol_space_timer_timeout():
	if stage != null and stage.has_method("check_matches"):
		stage.check_matches(output)
	output = ""
	label.text = output


func _on_label_resized():
	if stage != null and stage.has_method("toggle_collision_for_active_symbols"):
		stage.toggle_collision_for_active_symbols(output)
