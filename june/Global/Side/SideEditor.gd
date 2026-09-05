extends Node

var _current_file_path : String = ""

var current_editor_save := SideEditorResource.new()
var current_song_map := SideSongMap.new()

var _is_saved : bool = false

signal changed_current_song_map

signal save_changes

func _ready() -> void:
	current_editor_save = SideEditorResource.new()
	
	current_song_map = SideSongMap.new()
	current_song_map.difficulty = SideSongMap.Difficulty.EASY
	current_song_map.player = SideSongMap.Player.ONE
	
	current_editor_save.song_maps.append(current_song_map)

func new_file() -> void:
	_current_file_path = ""
	current_editor_save = SideEditorResource.new()
	
	current_song_map = SideSongMap.new()
	current_song_map.difficulty = SideSongMap.Difficulty.EASY
	current_song_map.player = SideSongMap.Player.ONE
	
	current_editor_save.song_maps.append(current_song_map)
	
	changed_current_song_map.emit()

func save_file(path : String) -> Error:
	save_changes.emit()
	
	var status = ResourceSaver.save(current_editor_save, path)
	if status == OK:
		_current_file_path = path
		_is_saved = true
	
	return status

func open_file(path : String) -> Error:
	current_editor_save = ResourceLoader.load(path)
	if current_editor_save and current_editor_save is SideEditorResource and not current_editor_save.song_maps.is_empty():
		_current_file_path = path
		_is_saved = true
		set_current_song_map(current_editor_save.song_maps[0])
		return OK
	return FAILED

func set_current_song_map(song_map : SideSongMap) -> void:
	current_song_map = song_map
	changed_current_song_map.emit()

func get_song_map(difficulty : int, player : int) -> SideSongMap:
	for song_map in SideEditor.current_editor_save.song_maps:
		if song_map.difficulty == difficulty and song_map.player == player:
			return song_map
	
	return null

func is_saved() -> bool:
	return _is_saved

func changed_file() -> void:
	_is_saved = false

func get_file_path() -> String:
	return _current_file_path
