extends Node2D

var active_symbols = []
var lives = 3
var score = 0
var shift_up_offset = 100
@onready var settings = preload("res://settings.tres")
@onready var hide_codes = settings.hide_codes
@onready var symbol_scene = preload("res://scenes/symbol.tscn")
@onready var dict = preload("res://scripts/code_dict.gd")
@onready var endgame_menu = preload("res://scenes/endgame_menu.tscn")
@onready var spawn_point = $Path2D/SpawnPoint
@onready var counter = $Counter
@onready var pause_menu = $PauseMenu
@onready var camera = $Camera2D
signal shake(time: float)


func _ready():
	counter.text = str(lives)
	$ScoreBoard.text = str(score)


func _physics_process(delta):
	spawn_point.progress_ratio += 0.1 * delta
	if Input.is_action_just_pressed("ui_cancel"):
		pause()


func pause():
	get_tree().paused = true
	pause_menu.set_deferred("visible", true)
	pause_menu.resume_button.grab_focus()


func check_matches(pattern):
	var symbols_for_elimination = []
	for symbol in active_symbols:
		if symbol.code == pattern:
			symbols_for_elimination.append(symbol)
	if len(symbols_for_elimination) == 1:
		score += ceili(return_global_y($LifeLossZone) - return_global_y(symbols_for_elimination[0]))
		symbols_for_elimination[0].destroy()
		$ScoreBoard.text = str(score)
		active_symbols.erase(symbols_for_elimination[0])
	elif len(symbols_for_elimination) > 1:
		var global_ys = symbols_for_elimination.map(return_global_y)
		var max_y = -1
		var idx_of_max_y = null
		for idx in range(len(global_ys)):
			if global_ys[idx] > max_y:
				max_y = global_ys[idx]
				idx_of_max_y = idx
		score += ceili(return_global_y($LifeLossZone) - global_ys[idx_of_max_y])
		$ScoreBoard.text = str(score)
		symbols_for_elimination[idx_of_max_y].destroy()
		active_symbols.erase(symbols_for_elimination[idx_of_max_y])


func return_global_y(node: Node2D):
	return node.global_position.y


func generate(serial_number):
	#Spawns a symbol with a corresponding code
	var instance = symbol_scene.instantiate()
	instance.character = dict.CHARACTERS[serial_number]
	instance.code = dict.CODES[serial_number]
	if not hide_codes:
		instance.code_text = instance.code
	instance.global_position = spawn_point.global_position
	active_symbols.append(instance)
	get_tree().get_root().add_child(instance)


func deduct_life():
	lives -= 1
	if lives < 0:
		lives = 0
	counter.text = str(lives)
	if lives == 0:
		lose()
	else:
		shift_up()
	shake.emit(0.5)


func shift_up():
	for symbol in active_symbols:
		symbol.global_position.y -= shift_up_offset


func kill_all_symbols():
	for symbol in active_symbols:
		symbol.queue_free()


func lose():
	kill_all_symbols()
	active_symbols = []
	$GenerationTimer.stop()
	counter.text = ""
	$ScoreBoard.text = ""
	var instance = endgame_menu.instantiate()
	instance.label_text = "Final score: " + str(score)
	add_child(instance)


func _on_generation_timer_timeout():
	generate(randi() % len(dict.CODES))
	$GenerationTimer.wait_time = 2 + randi_range(-3, 3) * 0.25


func _on_life_loss_zone_area_entered(area):
	if area.is_in_group("symbols"):
		area.destroy()
		active_symbols.erase(area)
		deduct_life()
