extends Camera2D


func _ready():
	set_process(false)


func _on_camera_shake(time):
	set_process(true)
	$ShakeTimer.wait_time = time
	$ShakeTimer.start()


func _process(_delta):
	position.x = randi_range(-1, 1) * 5
	position.y = randi_range(-1, 1) * 5


func _on_shake_timer_timeout():
	position = Vector2.ZERO
	set_process(false)
