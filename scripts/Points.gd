extends Control

var upward_speed = -50
var text = ""
@onready var label = $Label
@onready var fadeout = $Fadeout 


func _ready():
	label.text = text


func _process(delta):
	position.y += delta * upward_speed
	modulate.a = fadeout.time_left * 4


func _on_fadeout_timeout():
	queue_free()
