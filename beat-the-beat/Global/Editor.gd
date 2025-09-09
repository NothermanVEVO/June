extends Node

enum Scenes {NONE, SETTINGS, COMPOSER}
var _current_scene : Scenes

var _editor_menu_bar_scene := load("res://Editor/Editor Composer.tscn")
@onready var editor_composer : EditorComposer = _editor_menu_bar_scene.instantiate()

var _editor_settings_scene := load("res://Editor/EditorSettings.tscn")
@onready var editor_settings : SettingsEditor = _editor_settings_scene.instantiate()

var is_on_editor : bool = false
var _is_saved : bool = true

var _dialog_confirmation_id : int

signal file_saved

func _ready() -> void:
	get_tree().root.close_requested.connect(_on_close_requested)
	DialogConfirmation.confirmed.connect(_confirmation_dialog_confirmed)
	DialogConfirmation.canceled.connect(_confirmation_dialog_canceled)
	
	## TEMP, REMOVE LATER TODO WARNING NOTE BUG
	#get_tree().root.add_child.call_deferred(editor_composer)
	#get_tree().root.add_child.call_deferred(editor_settings)
	#_current_scene = Scenes.SETTINGS
	#editor_composer.visible = false
	#editor_settings.visible = true
	#is_on_editor = true
	
	get_tree().set_auto_accept_quit(false)

func _process(_delta: float) -> void:
	#print(_is_saved)
	pass

func get_current_scene() -> Scenes:
	return _current_scene

func is_saved() -> bool:
	return _is_saved

func changed_editor() -> void:
	_is_saved = false

func saved_file() -> void:
	file_saved.emit.call_deferred()
	_is_saved = true

func change_to_composer() -> void:
	editor_composer.visible = true
	editor_settings.visible = false
	_current_scene = Scenes.COMPOSER
	Song.set_time(editor_composer.song_time_pos)

func change_to_settings() -> void:
	editor_composer.song_time_pos = Song.get_time()
	editor_composer.visible = false
	editor_settings.visible = true
	editor_settings.play_song_button.text = "Play"
	_current_scene = Scenes.SETTINGS
	Song.set_time(0.0)

func load_resource(song_resource : SongResource) -> void:
	editor_settings.load_editor(song_resource.name, song_resource.author, song_resource.track, song_resource.BPM, song_resource.creator, 
	song_resource.song_time_sample, song_resource.video_time_sample, song_resource.song, song_resource.icon, song_resource.image, song_resource.video)
	
	editor_composer.editor_menu_bar.load_song_maps(song_resource.song_maps)

func to_resource() -> SongResource:
	return SongResource.new(editor_settings.get_song_name(), editor_settings.get_author_name(), editor_settings.get_BPM_value(), 
	editor_settings.get_track_name(), editor_settings.get_creator_name(), editor_settings.get_song_path(), editor_settings.get_image_path(), editor_settings.get_video_path(), 
	editor_settings.get_icon_path(), EditorMenuBar.get_memory_saved_song_maps(), editor_settings.get_song_time_sample(), editor_settings.get_video_time_sample())

func _on_close_requested() -> void:
	if not _is_saved:
		_dialog_confirmation_id = DialogConfirmation.pop_up("Quit without saving", "Save and quit", "You have unsaved changes.")
	else:
		get_tree().quit()

func _confirmation_dialog_confirmed() -> void: ## QUIT WITH SAVING
	var saved_id : int
	if _dialog_confirmation_id != DialogConfirmation.get_last_caller():
		return
	if FileMenu.get_file_path():
		FileMenu.save_file(FileMenu.get_file_path())
		await file_saved
		get_tree().quit()
	else:
		saved_id = FileMenu.save()
		await file_saved
		if saved_id == FileMenu.get_last_saved_id():
			get_tree().quit()

func _confirmation_dialog_canceled() -> void: ## QUIT WITHOUT SAVING
	if _dialog_confirmation_id == DialogConfirmation.get_last_caller():
		get_tree().quit()
