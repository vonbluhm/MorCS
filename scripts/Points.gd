extends Control

var upward_speed = -50
var text = ""


func _ready():
	$Label.text = text


func _process(delta):
	position.y += delta * upward_speed
	modulate.a = $Fadeout.time_left * 4


func _on_fadeout_timeout():
	queue_free()
