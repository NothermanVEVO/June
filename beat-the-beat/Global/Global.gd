extends Node

const EDITOR_PATH : String = "user://editor"
const SONGS_PATH : String = "user://songs"

var rng := RandomNumberGenerator.new()

## REFERS TO THE SPEED INSIDE THE GEAR CLASS
signal speed_changed

## REFERS TO THE MAX SIZE Y IN THE GEAR CLASS
signal changed_max_size_y

const HIGHLIGHT_SHADER = preload("res://shaders/Highlight.gdshader")

var _mouse_effect : MouseEffect

var file_dialog := FileDialog.new()

func _ready() -> void:
	_mouse_effect = MouseEffect.new()
	add_child(_mouse_effect)
	
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_USERDATA
	file_dialog.use_native_dialog = true
	
	add_child(file_dialog)
	#file_dialog.popup()
	if not DirAccess.dir_exists_absolute(EDITOR_PATH):
		DirAccess.make_dir_absolute(EDITOR_PATH)
	if not DirAccess.dir_exists_absolute(SONGS_PATH):
		DirAccess.make_dir_absolute(SONGS_PATH)
	

#func _process(delta: float) -> void:
	##print_orphan_nodes() ## NOTE USE THIS TO CHECK FOR POSSIBLE MEMORY LEAK
	#pass

func set_mouse_effect(effect : MouseEffect.Effect) -> void:
	_mouse_effect.set_type(effect)

func get_percentage_between(start: float, end: float, value: float) -> float:
	if end == start:
		return 0.0
	return (value - start) / (end - start)

func get_UUID() -> String:
	var values = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
	var begin := ""
	var middle := ""
	var end := ""
	
	for i in range(6):
		begin += values.substr(rng.randi_range(0, values.length() - 1), 1)
	for i in range(4):
		middle += values.substr(rng.randi_range(0, values.length() - 1), 1)
	for i in range(10):
		end += values.substr(rng.randi_range(0, values.length() - 1), 1)
	
	return begin + "-" + middle + "-" + end
