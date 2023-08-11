extends Node2D

var output = "" 
const DOT = "."
const DASH = "-"

@onready var stage = get_parent()
@onready var label = $Label
@onready var dot_dash = $DotDashTimer
@onready var end_of_symbol = $SymbolSpaceTimer
@onready var generator_scene = preload("res://scenes/generator.tscn")
@onready var settings = preload("res://settings.tres")
var generator = null
signal output_changed


func _ready():
	output_changed.connect(_on_output_changed)


func _process(_delta):
	if Input.is_action_just_pressed("button_pressed"):
		dot_dash.start()
		end_of_symbol.stop()
		var instance = generator_scene.instantiate()
		instance.pulse_hz = settings.beep_frequency
		generator = instance
		add_child(instance)
	if Input.is_action_just_released("button_pressed"):
		if not dot_dash.is_stopped():
			dot_dash.stop()
			output += DOT
			label.text = output
			output_changed.emit()
		end_of_symbol.start()
		if generator != null:
			generator.queue_free()


func _on_dot_dash_timer_timeout():
	output += DASH
	label.text = output
	output_changed.emit()


func _on_symbol_space_timer_timeout():
	if stage != null and stage.has_method("check_matches"):
		stage.check_matches(output)
	output = ""
	label.text = output
	output_changed.emit()


func _on_output_changed():
	if stage != null and stage.has_method("toggle_collision_for_active_symbols"):
		stage.toggle_collision_for_active_symbols(output)
