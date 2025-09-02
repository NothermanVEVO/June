extends Node

var _editor_menu_bar_scene := load("res://Editor/Editor Composer.tscn")
@onready var editor_composer : EditorComposer = _editor_menu_bar_scene.instantiate()

var _editor_settings_scene := load("res://Editor/EditorSettings.tscn")
@onready var editor_settings : SettingsEditor = _editor_settings_scene.instantiate()

func _ready() -> void: ## TEMP, REMOVE LATER
	get_tree().root.add_child.call_deferred(editor_composer)
	get_tree().root.add_child.call_deferred(editor_settings)
	editor_composer.visible = false
	editor_settings.visible = true

func change_to_composer() -> void:
	editor_composer.visible = true
	editor_settings.visible = false

func change_to_settings() -> void:
	editor_composer.visible = false
	editor_settings.visible = true

func to_resource() -> SongResource:
	return SongResource.new(editor_settings.get_song_name(), editor_settings.get_author_name(), editor_settings.get_BPM_value(), 
	editor_settings.get_track_name(), editor_settings.get_song_path(), editor_settings.get_image_path(), editor_settings.get_video_path(), 
	editor_settings.get_icon_path(), EditorMenuBar.get_memory_saved_song_maps(), editor_settings.get_song_time_sample(), editor_settings.get_video_time_sample())
