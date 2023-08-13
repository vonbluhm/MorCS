extends Area2D


var character: String = ""
var code: String = ""
var code_text: String = ""
@onready var speed: int = ceili(get_window().size.y * 0.18)
var random_component: int = 0
var value: int = 500
@onready var label: Control = $Label
@onready var code_label: Control = $Label2
@onready var sprite: Node2D = $AnimatedSprite2D
@onready var particles: Node2D = $GPUParticles2D
@onready var despawn_timer: Timer = $Timer


func _ready():
	add_to_group("symbols")
	label.text = character
	code_label.text = str(code_text)
	random_component = randi_range(-2, 2)


func _process(delta):
	translate(Vector2(0, (speed * (1 + random_component * 0.1)) * delta))


func destroy():
	label.hide()
	code_label.hide()
	sprite.hide()
	set_deferred("collision_layer", 0)
	particles.emitting = true
	set_process(false)
	despawn_timer.start()


func _on_timer_timeout():
	queue_free()
