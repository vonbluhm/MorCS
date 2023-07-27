extends Node2D

var active_symbols = []
@onready var symbol_scene = preload("res://scenes/symbol.tscn")
@onready var dict = preload("res://scripts/code_dict.gd")
@onready var spawn_point = $Path2D/SpawnPoint


func _physics_process(delta):
	spawn_point.progress_ratio += 0.1 * delta


func check_matches(pattern):
	var symbols_for_elimination = []
	for symbol in active_symbols:
		if symbol.code == pattern:
			symbols_for_elimination.append(symbol)
	if len(symbols_for_elimination) == 1:
		symbols_for_elimination[0].destroy()
		active_symbols.erase(symbols_for_elimination[0])
	elif len(symbols_for_elimination) > 1:
		var global_ys = symbols_for_elimination.map(return_global_y)
		var max_y = -1
		var idx_of_max_y = null
		for idx in range(len(global_ys)):
			if global_ys[idx] > max_y:
				max_y = global_ys[idx]
				idx_of_max_y = idx
		symbols_for_elimination[idx_of_max_y].destroy()
		active_symbols.erase(symbols_for_elimination[idx_of_max_y])



func return_global_y(node: Node2D):
	return node.global_position.y


func generate(serial_number):
	#Spawns a symbol with a corresponding code
	var instance = symbol_scene.instantiate()
	instance.character = dict.CHARACTERS[serial_number]
	instance.code = dict.CODES[serial_number]
	instance.global_position = spawn_point.global_position
	active_symbols.append(instance)
	get_tree().get_root().add_child(instance)


func _on_generation_timer_timeout():
	generate(randi_range(0, 25))
	$GenerationTimer.wait_time = 2 + randi_range(-3, 3) * 0.25


func _on_life_loss_zone_area_entered(area):
	if area.is_in_group("symbols"):
		area.destroy()
		active_symbols.erase(area)
