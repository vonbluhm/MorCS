extends Control

var upward_speed: int = -50
var text: String = ""
@onready var label: Label = $Label
@onready var fadeout: Timer = $Fadeout 


func _ready():
	label.text = text


func _process(delta):
	position.y += delta * upward_speed
	modulate.a = fadeout.time_left * 4


func _on_fadeout_timeout():
	queue_free()
