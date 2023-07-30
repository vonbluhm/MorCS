extends Area2D


var character = ""
var code = ""
var code_text = ""
var speed = 100
var random_component = 0
@onready var code_label = $Label2


func _ready():
	add_to_group("symbols")
	$Label.text = character
	code_label.text = str(code_text)
	random_component = randi_range(-2, 2)


func _physics_process(delta):
	translate(Vector2(0, (speed * (1 + random_component * 0.1)) * delta))


func destroy():
	queue_free()
