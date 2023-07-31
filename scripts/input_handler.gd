extends Node2D

var output = "" 
const DOT = "."
const DASH = "-"
@onready var stage = get_parent()


func _process(_delta):
	if Input.is_action_just_pressed("button_pressed"):
		$DotDashTimer.start()
		$SymbolSpaceTimer.stop()
	if Input.is_action_just_released("button_pressed"):
		if not $DotDashTimer.is_stopped():
			$DotDashTimer.stop()
			output += DOT
			$Label.text = output
		$SymbolSpaceTimer.start()
	


func _on_dot_dash_timer_timeout():
	output += DASH
	$Label.text = output


func _on_symbol_space_timer_timeout():
	#match the output with active letters
	if stage != null:
		stage.check_matches(output)
	output = ""
	$Label.text = output