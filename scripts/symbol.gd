extends Area2D


var character = ""
var code: String = ""
var code_text = ""
@onready var speed = get_window().size.y * 0.18
var random_component = 0
var value = 500
@onready var code_label = $Label2


func _ready():
	add_to_group("symbols")
	$Label.text = character
	code_label.text = str(code_text)
	random_component = randi_range(-2, 2)


func _process(delta):
	translate(Vector2(0, (speed * (1 + random_component * 0.1)) * delta))


func destroy():
	$Label.hide()
	code_label.hide()
	$AnimatedSprite2D.hide()
	set_deferred("collision_layer", 0)
	$GPUParticles2D.emitting = true
	set_process(false)
	$Timer.start()


func _on_timer_timeout():
	queue_free()
