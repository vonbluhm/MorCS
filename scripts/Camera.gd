extends Camera2D

@onready var shake_timer = $ShakeTimer

func _ready():
	set_process(false)


func _on_camera_shake(time):
	set_process(true)
	shake_timer.wait_time = time
	shake_timer.start()


func _process(_delta):
	offset.x = randi_range(-1, 1) * 5
	offset.y = randi_range(-1, 1) * 5


func _on_shake_timer_timeout():
	offset = Vector2.ZERO
	set_process(false)
