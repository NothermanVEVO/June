extends Node

var speed : float = 1.0
var gear_transparency : float = 0.5
var gear_position : GameSettingsScreen.GearPositions = GameSettingsScreen.GearPositions.CENTER

var _gear_type : Gear.Type
var _song_map : SongMap
var _song : AudioStream
var _video_stream : VideoStream
var _texture : Texture

var _selection_state_saved : bool = false

var _selection_UUID : String
var _selection_tab : int
var _selection_difficulty : SongMap.Difficulty

signal game_ended(score : int, combo : int, section : Dictionary)

func _ready() -> void:
	game_ended.connect(_game_ended)

func save_selection_state(UUID : String, tab_selected : int, difficulty : SongMap.Difficulty) -> void:
	_selection_state_saved = true
	_selection_UUID = UUID
	_selection_tab = tab_selected
	_selection_difficulty = difficulty

func change_to_music_player(gear_type : Gear.Type, song_map : SongMap, song, video_stream = null, texture = null) -> void:
	_gear_type = gear_type
	_song_map = song_map
	_song = song
	_video_stream = video_stream
	_texture = texture
	
	get_tree().change_scene_to_packed(Global.MUSIC_PLAYER_SCENE)

func load_music_player(music_player : MusicPlayer) -> void:
	music_player.load_by_vars(_gear_type, _song_map, _song, _video_stream, _texture)
	music_player.start()

func change_to_selection() -> void:
	_gear_type = 0
	_song_map = null
	_song = null
	_video_stream = null
	_texture = null
	get_tree().change_scene_to_packed(Global.SELECTION_SCREEN_SCENE)

func has_selection_state_saved() -> bool:
	return _selection_state_saved

func load_selection_state_saved(songs_selection : SongsSelection) -> void:
	if not _selection_state_saved:
		return
	_selection_state_saved = false
	
	songs_selection.load_state(_selection_UUID, _selection_tab, _selection_difficulty)
	
	_selection_UUID = ""
	_selection_tab = -1
	_selection_difficulty = 0

func _game_ended(score : int, combo : int, section : Dictionary) -> void:
	print(score)
	print(combo)
	print(section)
	await get_tree().create_timer(5).timeout
	change_to_selection()
