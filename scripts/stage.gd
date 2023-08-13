extends Node2D

var active_symbols: Array = []
var lives: int = 3
var score: int = 0
var points_left_before_award: int = 5000
var shift_up_offset: int = 100
var config: ConfigFile = ConfigFile.new()
@onready var used_dict: Dictionary
@onready var hide_codes: bool = Settings.hide_codes
@onready var high_score: int = Settings.high_score
@onready var symbol_scene: PackedScene = preload("res://scenes/symbol.tscn")
@onready var points_popup: PackedScene = preload("res://scenes/points_popup.tscn")
@onready var dicts: Script = preload("res://scripts/code_dict.gd")
@onready var spawn_point: PathFollow2D = $Path2D/SpawnPoint
@onready var background: ColorRect = $Control/ColorRect
@onready var heartx: TextureRect = $Control/HeartX
@onready var counter: Label = $Control/HeartX/Counter
@onready var lifebar: TextureProgressBar = $Control/TextureProgressBar
@onready var scoreboard: ProgressBar = $Control/ScoreBoard
@onready var scoreboard_label: Label = $Control/ScoreBoard/Label
@onready var pause_menu: Control = $Control/PauseMenu
@onready var endgame_menu: Control = $Control/EndGameMenu
@onready var camera: Camera2D = $Camera2D
@onready var hitzone: Area2D = $LifeLossZone
@onready var sfx_destroyed: AudioStreamPlayer2D = $Destroyed
@onready var sfx_hit: AudioStreamPlayer2D  = $LifeLost
@onready var sfx_extralife: AudioStreamPlayer2D  = $LifeAwarded
@onready var sfx_lost: AudioStreamPlayer2D  = $GO
@onready var sfx_lost_with_hs: AudioStreamPlayer2D  = $GO_HS
@onready var input_handler: Node2D = $InputHandler
@onready var spawning_timer: Timer = $GenerationTimer
signal shake(time: float)


func _ready():
	scoreboard_label.text = str(score)
	match Settings.dict_option:
		0:
			used_dict = dicts.DICT_ITU
		1:
			used_dict = dicts.DICT_CYR
	config.load("user://settings.ini")
	
	var window_size: Vector2i = get_window().size
	background.global_position = Vector2i(-50, -50)
	#This overlap prevents revealing the background
	background.set_size(window_size + Vector2i(100, 100))
	hitzone.global_position.y = window_size.y


func _physics_process(delta):
	spawn_point.progress_ratio += 0.1 * delta
	if Input.is_action_just_pressed("ui_cancel") and not get_tree().paused:
		pause()


func pause():
	get_tree().paused = true
	var img: Image = get_viewport().get_texture().get_image()
	pause_menu.sprite.texture = ImageTexture.create_from_image(img)
	pause_menu.set_deferred("visible", true)
	pause_menu.resume_button.grab_focus()


func check_matches(pattern):
	var symbols_for_elimination: Array = []
	for symbol in active_symbols:
		if symbol.code == pattern:
			symbols_for_elimination.append(symbol)
	if len(symbols_for_elimination) >= 1:
		var global_ys: Array = symbols_for_elimination.map(return_global_y)
		var max_y = -1
		var idx_of_max_y = null
		for idx in range(len(global_ys)):
			if global_ys[idx] > max_y:
				max_y = global_ys[idx]
				idx_of_max_y = idx
		var points_to_add: int = ceili((1 - global_ys[idx_of_max_y]/return_global_y($LifeLossZone))*500)
		points_to_add = ceili(points_to_add  * (1 + symbols_for_elimination[idx_of_max_y].random_component * 0.1))
		if points_to_add >= 0:
			var instance = points_popup.instantiate()
			instance.text = str(points_to_add)
			symbols_for_elimination[idx_of_max_y].add_child(instance)
			score += points_to_add
			points_left_before_award -= points_to_add
			if points_left_before_award <= 0:
				award_life() 
			scoreboard_label.text = str(score)
			scoreboard.value = score
		symbols_for_elimination[idx_of_max_y].destroy()
		active_symbols.erase(symbols_for_elimination[idx_of_max_y])
		sfx_destroyed.play()


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
		sfx_extralife.play()
		lives += 1
		counter.text = str(lives) if lives > 3 else ""
		lifebar.value = lives
		
	points_left_before_award += 15000
	scoreboard.min_value = scoreboard.max_value
	scoreboard.max_value += 15000


func deduct_life():
	lives -= 1
	counter.text = str(lives) if lives > 3 else ""
	lifebar.value = lives
	if lives < 0:
		lives = 0
	if lives == 0:
		lose()
	else:
		sfx_hit.play()
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
	input_handler.queue_free()
	spawning_timer.stop()
	counter.queue_free()
	lifebar.queue_free()
	scoreboard.queue_free()
	endgame_menu.visible = true
	endgame_menu.try_again_button.grab_focus()
	if score > high_score:
		endgame_menu.label.text = "New high score: " + str(score)
		config.set_value("Player1", "high_score", score)
		config.save("user://settings.ini")
		sfx_lost_with_hs.play()
	else:
		endgame_menu.label.text = "Final score: " + str(score)
		sfx_lost.play()


func _on_generation_timer_timeout():
	generate(randi() % used_dict.size())
	spawning_timer.wait_time = 2 + randi_range(-3, 3) * 0.25


func _on_life_loss_zone_area_entered(area):
	if area.is_in_group("symbols"):
		area.destroy()
		active_symbols.erase(area)
		deduct_life()


func _on_texture_progress_bar_value_changed(value):
	lifebar.set_deferred("visible", value <= 3)
	heartx.set_deferred("visible", value > 3)
