extends Node2D

var active_symbols = []
var lives = 3
var score = 0
var points_left_before_award = 10000
var shift_up_offset = 100
var config = ConfigFile.new()
@onready var settings = preload("res://settings.tres")
@onready var used_dict
@onready var hide_codes = settings.hide_codes
@onready var high_score = settings.high_score
@onready var symbol_scene = preload("res://scenes/symbol.tscn")
@onready var dicts = preload("res://scripts/code_dict.gd")
@onready var spawn_point = $Path2D/SpawnPoint
@onready var counter = $Control/Counter
@onready var lifebar = $Control/Counter/TextureProgressBar
@onready var scoreboard = $Control/ScoreBoard
@onready var pause_menu = $Control/PauseMenu
@onready var endgame_menu = $Control/EndGameMenu
@onready var camera = $Camera2D
signal shake(time: float)


func _ready():
	counter.text = str(lives)
	scoreboard.text = str(score)
	match settings.dict_option:
		0:
			used_dict = dicts.DICT_ITU
		1:
			used_dict = dicts.DICT_CYR
	config.load("user://settings.ini")
	
	var window_size = get_window().size
	$Control/ColorRect.global_position = Vector2i(-50, -50)
	#This overlap prevents revealing the background
	$Control/ColorRect.set_size(window_size + Vector2i(100, 100))
	$LifeLossZone.global_position.y = window_size.y


func _physics_process(delta):
	spawn_point.progress_ratio += 0.1 * delta
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()


func pause():
	get_tree().paused = true
	var img = get_viewport().get_texture().get_image()
	pause_menu.sprite.texture = ImageTexture.create_from_image(img)
	pause_menu.set_deferred("visible", true)
	pause_menu.resume_button.grab_focus()


func check_matches(pattern):
	var symbols_for_elimination = []
	for symbol in active_symbols:
		if symbol.code == pattern:
			symbols_for_elimination.append(symbol)
	if len(symbols_for_elimination) >= 1:
		var global_ys = symbols_for_elimination.map(return_global_y)
		var max_y = -1
		var idx_of_max_y = null
		for idx in range(len(global_ys)):
			if global_ys[idx] > max_y:
				max_y = global_ys[idx]
				idx_of_max_y = idx
		var points_to_add = ceili((1 - global_ys[idx_of_max_y]/return_global_y($LifeLossZone))*500)
		points_to_add = ceili(points_to_add  * (1 + symbols_for_elimination[idx_of_max_y].random_component * 0.1))
		if points_to_add >= 0:
			score += points_to_add
			points_left_before_award -= points_to_add
			if points_left_before_award <= 0:
				award_life() 
		scoreboard.text = str(score)
		symbols_for_elimination[idx_of_max_y].destroy()
		active_symbols.erase(symbols_for_elimination[idx_of_max_y])
		$Destroyed.play()


func return_global_y(node: Node2D):
	return node.global_position.y


func generate(serial_number: int):
	#Spawns a symbol with a corresponding code
	var instance = symbol_scene.instantiate()
	instance.character = used_dict[serial_number][0]
	instance.code = used_dict[serial_number][1]
	if not hide_codes:
		instance.code_text = instance.code
	instance.global_position = spawn_point.global_position
	active_symbols.append(instance)
	add_child(instance)


func toggle_collision_for_active_symbols(mask: String):
	for symbol in active_symbols:
		if symbol.code.begins_with(mask) and mask != "":
			symbol.set_collision_layer(0)
		else:
			symbol.set_collision_layer(1)


func award_life():
	if lives < 9:
		$LifeAwarded.play()
		lives += 1
		lifebar.value = lives
		counter.text = str(lives)
	points_left_before_award += 30000


func deduct_life():
	lives -= 1
	lifebar.value = lives
	if lives < 0:
		lives = 0
	counter.text = str(lives)
	if lives == 0:
		lose()
	else:
		$LifeLost.play()
		shift_up()
	shake.emit(0.5)


func shift_up():
	for symbol in active_symbols:
		symbol.global_position.y -= shift_up_offset


func kill_all_symbols():
	for child in get_children():
		if child.is_in_group("symbols"):
			child.queue_free()
	active_symbols = []


func lose():
	for symbol in active_symbols:
		symbol.queue_free()
	active_symbols = []
	$InputHandler.queue_free()
	$GenerationTimer.stop()
	counter.queue_free()
	scoreboard.queue_free()
	endgame_menu.visible = true
	endgame_menu.try_again_button.grab_focus()
	if score > high_score:
		endgame_menu.label.text = "New high score: " + str(score)
		config.set_value("Player1", "high_score", score)
		config.save("user://settings.ini")
		$GO_HS.play()
	else:
		endgame_menu.label.text = "Final score: " + str(score)
		$GO.play()


func _on_generation_timer_timeout():
	generate(randi() % used_dict.size())
	$GenerationTimer.wait_time = 2 + randi_range(-3, 3) * 0.25


func _on_life_loss_zone_area_entered(area):
	if area.is_in_group("symbols"):
		area.destroy()
		active_symbols.erase(area)
		deduct_life()


func _on_texture_progress_bar_value_changed(value):
	lifebar.set_deferred("visible", value <= 3)
