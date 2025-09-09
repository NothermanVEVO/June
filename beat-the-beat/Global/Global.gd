extends Node

enum TitleType {BASE, EDITOR_UNSAVED, EDITOR_SAVED, EDITOR_SAVED_CHANGED}

const EDITOR_PATH : String = "user://editor"
const SONGS_PATH : String = "user://songs"

var rng := RandomNumberGenerator.new()

var main_music_player : MusicPlayer

@warning_ignore("unused_signal")
## REFERS TO THE SPEED INSIDE THE GEAR CLASS
signal speed_changed

@warning_ignore("unused_signal")
## REFERS TO THE MAX SIZE Y IN THE GEAR CLASS
signal changed_max_size_y

const HIGHLIGHT_SHADER = preload("res://shaders/Highlight.gdshader")

var _mouse_effect : MouseEffect

func _ready() -> void:
	_mouse_effect = MouseEffect.new()
	add_child(_mouse_effect)
	
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

func set_window_title(type : TitleType) -> void:
	match type:
		TitleType.BASE:
			DisplayServer.window_set_title("June")
		TitleType.EDITOR_UNSAVED:
			DisplayServer.window_set_title("June - Editor - Unsaved File")
		TitleType.EDITOR_SAVED:
			DisplayServer.window_set_title("June - Editor - [" + FileMenu.get_file_path() + "]")
		TitleType.EDITOR_SAVED_CHANGED:
			DisplayServer.window_set_title("June - Editor - [" + FileMenu.get_file_path() + "] (*)")

func text_to_time(text : String) -> float:
	var values := text.split(":")
	values[0] = "00" if not values[0] else "0" + values[0] if values[0].length() == 1 else values[0]
	values[1] = "00" if not values[1] else "0" + values[1] if values[1].length() == 1 else values[1]
	values[2] = "000" if not values[2] else values[2] + "00" if values[2].length() == 1 else values[2] + "0" if values[2].length() == 2 else values[2]
			
	var minutes : int = str_to_var(values[0])
	var seconds : int = str_to_var(values[1])
	var miliseconds : float = str_to_var("0." + values[2])
	var absolute_seconds : float = minutes * 60 + seconds + (miliseconds + 0.0005) # !!BUG!! THE DECIMAL NUMBER DECREASES IN 0.001, AND INCREASES IN 0.0001 WHEN PUTTING MORE THAN 3 NUMBER IN THE DECIMAL, SOLVE THIS LATER
	absolute_seconds = absolute_seconds if absolute_seconds <= Song.get_duration() else Song.get_duration()
	return absolute_seconds
