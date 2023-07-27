extends Area2D


var character = ""
var code = ""
var speed = 50
var random_component = 0


func _ready():
	add_to_group("symbols")
	$Label.text = character
	$Label2.text = str(code)
	random_component = randi_range(-2, 2)


func _physics_process(delta):
	translate(Vector2(0, (speed + 10 * random_component) * delta))


func destroy():
	queue_free()
