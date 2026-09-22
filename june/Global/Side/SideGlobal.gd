extends Node

@onready var _side_game_scene : PackedScene = load("res://Side/GamePlayer/SideGame.tscn")

var _asked_song_map : SideSongMap = null
var _asked_to_play_from_editor : bool = false

func play_song_map(song_map : SideSongMap, asked_from_editor : bool) -> void:
	_asked_song_map = song_map
	_asked_to_play_from_editor = asked_from_editor
	get_tree().change_scene_to_packed(_side_game_scene)

func get_asked_song_map() -> SideSongMap:
	return _asked_song_map

func was_asked_to_play_from_editor() -> bool:
	return _asked_to_play_from_editor
