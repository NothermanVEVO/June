extends Node

enum TitleType {BASE, EDITOR_UNSAVED, EDITOR_SAVED, EDITOR_SAVED_CHANGED}

const EDITOR_PATH : String = "user://editor"
const SONGS_PATH : String = "user://songs"
const SETTINGS_PATH : String = "user://settings.json"
const SAVE_PATH : String = "user://save.json"

var rng := RandomNumberGenerator.new()

var main_music_player : MusicPlayer

@warning_ignore("unused_signal")
## REFERS TO THE SPEED INSIDE THE GEAR CLASS
signal speed_changed

@warning_ignore("unused_signal")
## REFERS TO THE MAX SIZE Y IN THE GEAR CLASS
signal changed_max_size_y

@warning_ignore("unused_signal")
## REFERS TO THE STATIC HITZONE Y IN THE NOTE HOLDER CLASS
signal changed_hitzone_y

const HIGHLIGHT_SHADER = preload("res://shaders/Highlight.gdshader")

var _mouse_effect : MouseEffect

var START_SCREEN_SCENE := load("res://Screens/StartScreen.tscn")
var SELECTION_SCREEN_SCENE := load("res://Screens/SelectionScreen/SelectionScreen.tscn")
var EDITOR_SCREEN_SCENE := load("res://Screens/EditorScreen.tscn")
var SETTING_SCREEN_SCENE := load("res://Screens/SettingsScreen.tscn")
var GAME_SETTING_SCREEN_SCENE := load("res://Screens/GameSettingsScreen.tscn")
var VIDEO_SCREEN_SCENE := load("res://Screens/VideoScreen.tscn")
var AUDIO_SCREEN_SCENE := load("res://Screens/AudioScreen.tscn")
var CONTROL_SCREEN_SCENE := load("res://Screens/ControlsScreen.tscn")
var MUSIC_PLAYER_SCENE := load("res://Music Player/MusicPlayer.tscn")

const SHINE_HIGHLIGHT := preload("res://shaders/Shine.gdshader")

var _settings_dictionary : Dictionary

func _ready() -> void:
	_mouse_effect = MouseEffect.new()
	add_child(_mouse_effect)
	
	if not DirAccess.dir_exists_absolute(EDITOR_PATH):
		DirAccess.make_dir_absolute(EDITOR_PATH)
	if not DirAccess.dir_exists_absolute(SONGS_PATH):
		DirAccess.make_dir_absolute(SONGS_PATH)
	if not FileAccess.file_exists(SETTINGS_PATH):
		_create_settings()
	else:
		_load_settings()
	if not FileAccess.file_exists(SAVE_PATH):
		create_save({})

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	#print_orphan_nodes() ## NOTE USE THIS TO CHECK FOR POSSIBLE MEMORY LEAK
	pass

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
	
	for i in range(12):
		begin += values.substr(rng.randi_range(0, values.length() - 1), 1)
	for i in range(10):
		middle += values.substr(rng.randi_range(0, values.length() - 1), 1)
	for i in range(16):
		end += values.substr(rng.randi_range(0, values.length() - 1), 1)
	
	return begin + "-" + middle + "-" + end

func set_window_title(type : TitleType) -> void:
	match type:
		TitleType.BASE:
			DisplayServer.window_set_title("June")
		TitleType.EDITOR_UNSAVED:
			DisplayServer.window_set_title("June - Editor - Unsaved File")
		TitleType.EDITOR_SAVED:
			if FileMenu.get_file_path():
				DisplayServer.window_set_title("June - Editor - [" + FileMenu.get_file_path().get_basename().get_file() + "]")
		TitleType.EDITOR_SAVED_CHANGED:
			if FileMenu.get_file_path():
				DisplayServer.window_set_title("June - Editor - [" + FileMenu.get_file_path().get_basename().get_file() + "] (*)")

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

func create_save(dictionary : Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(dictionary, "\t")
		file.store_string(json_string)
		file.close()

func get_save() -> Dictionary:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var result = json.parse(content)
	if result == OK:
		return json.get_data()
	return {}

func save_sample() -> Dictionary:
	return {
		"4 buttons": {
			"FACIL": {"combo": 0.0, "score": 0.0},
			"NORMAL": {"combo": 0.0, "score": 0.0},
			"HARD": {"combo": 0.0, "score": 0.0},
			"MAXIMUS": {"combo": 0.0, "score": 0.0}
		},
		"5 buttons": {
			"FACIL": {"combo": 0.0, "score": 0.0},
			"NORMAL": {"combo": 0.0, "score": 0.0},
			"HARD": {"combo": 0.0, "score": 0.0},
			"MAXIMUS": {"combo": 0.0, "score": 0.0}
		},
		"6 buttons": {
			"FACIL": {"combo": 0.0, "score": 0.0},
			"NORMAL": {"combo": 0.0, "score": 0.0},
			"HARD": {"combo": 0.0, "score": 0.0},
			"MAXIMUS": {"combo": 0.0, "score": 0.0}
		}
	}

func _create_settings() -> void:
	_settings_dictionary["game_speed"] = 1.0
	_settings_dictionary["game_gear_transparency"] = 0.5
	_settings_dictionary["game_gear_position"] = GameSettingsScreen.GearPositions.CENTER
	
	_settings_dictionary["video_mode"] = VideoScreen.Modes.FULLSCREEN
	_settings_dictionary["video_vsync"] = VideoScreen.Vsync.ACTIVATED
	_settings_dictionary["video_msaa"] = VideoScreen.MSAA.DISABLED
	
	_settings_dictionary["audio_main_volume"] = 0.5
	_settings_dictionary["audio_sfx"] = 1
	
	_settings_dictionary["1_4k"] = 83
	_settings_dictionary["2_4k"] = 68
	_settings_dictionary["3_4k"] = 75
	_settings_dictionary["4_4k"] = 76
	
	_settings_dictionary["1_5k"] = 83
	_settings_dictionary["2_5k"] = 68
	_settings_dictionary["3_5k"] = 74
	_settings_dictionary["4_5k"] = 75
	_settings_dictionary["5_5k"] = 76
	
	_settings_dictionary["1_6k"] = 83
	_settings_dictionary["2_6k"] = 68
	_settings_dictionary["3_6k"] = 70
	_settings_dictionary["4_6k"] = 74
	_settings_dictionary["5_6k"] = 75
	_settings_dictionary["6_6k"] = 76
	
	_settings_dictionary["video"] = true
	_settings_dictionary["particles"] = true
	_settings_dictionary["glow"] = true
	
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(_settings_dictionary, "\t")
		file.store_string(json_string)
		file.close()

func _load_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var result = json.parse(content)
	if result == OK:
		_settings_dictionary = json.get_data()
	
	_adjust_settings_dictionary()
	
	_load_video_settings()
	_load_audio_settings()
	_load_controls_settings()

func save_settings(dictionary : Dictionary) -> void:
	_settings_dictionary = dictionary
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		var json_string := JSON.stringify(_settings_dictionary, "\t")
		file.store_string(json_string)
		file.close()
		
		_load_video_settings()
		_load_audio_settings()
		_load_controls_settings()

func get_settings_dictionary() -> Dictionary:
	return _settings_dictionary

func _adjust_settings_dictionary() -> void:
	if not _settings_dictionary.has("game_speed"):
		_settings_dictionary["game_speed"] = 1.0
	if not _settings_dictionary.has("game_gear_transparency"):
		_settings_dictionary["game_gear_transparency"] = 0.5
	if not _settings_dictionary.has("game_gear_position"):
		_settings_dictionary["game_gear_position"] = GameSettingsScreen.GearPositions.CENTER
	
	if not _settings_dictionary.has("video_mode"):
		_settings_dictionary["video_mode"] = VideoScreen.Modes.FULLSCREEN
	if not _settings_dictionary.has("video_vsync"):
		_settings_dictionary["video_vsync"] = VideoScreen.Vsync.ACTIVATED
	if not _settings_dictionary.has("video_msaa"):
		_settings_dictionary["video_msaa"] = VideoScreen.MSAA.DISABLED
	
	if not _settings_dictionary.has("audio_main_volume"):
		_settings_dictionary["audio_main_volume"] = 0.5
	if not _settings_dictionary.has("audio_sfx"):
		_settings_dictionary["audio_sfx"] = 1
	
	if not _settings_dictionary.has("1_4k"):
		_settings_dictionary["1_4k"] = 83
	if not _settings_dictionary.has("2_4k"):
		_settings_dictionary["2_4k"] = 68
	if not _settings_dictionary.has("3_4k"):
		_settings_dictionary["3_4k"] = 75
	if not _settings_dictionary.has("4_4k"):
		_settings_dictionary["4_4k"] = 76
	
	if not _settings_dictionary.has("1_5k"):
		_settings_dictionary["1_5k"] = 83
	if not _settings_dictionary.has("2_5k"):
		_settings_dictionary["2_5k"] = 68
	if not _settings_dictionary.has("3_5k"):
		_settings_dictionary["3_5k"] = 74
	if not _settings_dictionary.has("4_5k"):
		_settings_dictionary["4_5k"] = 75
	if not _settings_dictionary.has("5_5k"):
		_settings_dictionary["5_5k"] = 76
	
	if not _settings_dictionary.has("1_6k"):
		_settings_dictionary["1_6k"] = 83
	if not _settings_dictionary.has("2_6k"):
		_settings_dictionary["2_6k"] = 68
	if not _settings_dictionary.has("3_6k"):
		_settings_dictionary["3_6k"] = 70
	if not _settings_dictionary.has("4_6k"):
		_settings_dictionary["4_6k"] = 74
	if not _settings_dictionary.has("5_6k"):
		_settings_dictionary["5_6k"] = 75
	if not _settings_dictionary.has("6_6k"):
		_settings_dictionary["6_6k"] = 76
	
	if not _settings_dictionary.has("video"):
		_settings_dictionary["video"] = true
	if not _settings_dictionary.has("particles"):
		_settings_dictionary["particles"] = true
	if not _settings_dictionary.has("glow"):
		_settings_dictionary["glow"] = true
	
	save_settings(_settings_dictionary)

func _load_game_settings() -> void:
	Game.speed = _settings_dictionary["game_speed"]
	Game.gear_transparency = _settings_dictionary["game_gear_transparency"]
	Game.gear_position = _settings_dictionary["game_gear_position"]

func _load_video_settings() -> void:
	match int(_settings_dictionary["video_mode"]):
		VideoScreen.Modes.WINDOW:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		VideoScreen.Modes.WINDOW_FULLSCREEN: ## I KNOW I KNOW
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		VideoScreen.Modes.FULLSCREEN: ## I KNOW I KNOW
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	match int(_settings_dictionary["video_vsync"]):
		VideoScreen.Vsync.ACTIVATED:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		VideoScreen.Vsync.DESACTIVATED:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	if not get_viewport():
		return
	match int(_settings_dictionary["video_msaa"]):
		VideoScreen.MSAA.DISABLED:
			get_viewport().msaa_2d = Viewport.MSAA_DISABLED
		VideoScreen.MSAA.TWO_X:
			get_viewport().msaa_2d = Viewport.MSAA_2X
		VideoScreen.MSAA.FOUR_X:
			get_viewport().msaa_2d = Viewport.MSAA_4X
		VideoScreen.MSAA.EIGHT_X:
			get_viewport().msaa_2d = Viewport.MSAA_8X

func _load_audio_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Song"), linear_to_db(_settings_dictionary["audio_main_volume"]))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effect"), linear_to_db(_settings_dictionary["audio_sfx"]))

func _load_controls_settings() -> void:
	## 4 KEYS
	_rebind_action("1_4k", _settings_dictionary["1_4k"])
	_rebind_action("2_4k", _settings_dictionary["2_4k"])
	_rebind_action("3_4k", _settings_dictionary["3_4k"])
	_rebind_action("4_4k", _settings_dictionary["4_4k"])
	
	## 5 KEYS
	_rebind_action("1_5k", _settings_dictionary["1_5k"])
	_rebind_action("2_5k", _settings_dictionary["2_5k"])
	_rebind_action("3_5k", _settings_dictionary["3_5k"])
	_rebind_action("4_5k", _settings_dictionary["4_5k"])
	_rebind_action("5_5k", _settings_dictionary["5_5k"])
	
	## 6 KEYS
	_rebind_action("1_6k", _settings_dictionary["1_6k"])
	_rebind_action("2_6k", _settings_dictionary["2_6k"])
	_rebind_action("3_6k", _settings_dictionary["3_6k"])
	_rebind_action("4_6k", _settings_dictionary["4_6k"])
	_rebind_action("5_6k", _settings_dictionary["5_6k"])
	_rebind_action("6_6k", _settings_dictionary["6_6k"])

func _rebind_action(action_name : String, physical_keycode : int) -> void:
	InputMap.erase_action(action_name)
	InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	InputMap.action_add_event(action_name, event)
