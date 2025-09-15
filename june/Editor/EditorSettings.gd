extends VBoxContainer

class_name SettingsEditor

enum Files{SONG = 0, ICON = 1, IMAGE = 2, VIDEO = 3}

@onready var file_dialog : FileDialog = $FileDialog
@onready var accept_dialog : AcceptDialog = $AcceptDialog

const DRAG_N_DROP_TEXT : String = "Select file or Drag and Drop here"
const VALID_AUDIO_EXTENSION : Array[String] = ["wav", "mp3", "ogg"]

@onready var song_button : Button = $HBoxContainer/Right/VBoxContainer/Song/SongButton
@onready var play_song_button : Button = $HBoxContainer/Right/VBoxContainer/Song/PlaySongButton
var _song_path : String = ""

@onready var icon_button : Button = $HBoxContainer/Right/VBoxContainer/Icon/IconButton
@onready var remove_icon_button : Button = $HBoxContainer/Right/VBoxContainer/Icon/RemoveIconButton
@onready var icon_texture : TextureRect = $HBoxContainer/Right/VBoxContainer/Icon/IconTexture
var _icon_path : String = ""

@onready var image_button : Button = $HBoxContainer/Right/VBoxContainer/Image/ImageButton
@onready var remove_image_button : Button = $HBoxContainer/Right/VBoxContainer/Image/RemoveImageButton
@onready var image_rect_texture : TextureRect = $HBoxContainer/Right/VBoxContainer/Image/ImageTexture
var _image_path : String = ""

@onready var video_button : Button = $HBoxContainer/Right/VBoxContainer/Video/VideoButton
@onready var remove_video_button : Button = $HBoxContainer/Right/VBoxContainer/Video/RemoveVideoButton
@onready var video_player : VideoStreamPlayer = $HBoxContainer/Right/VBoxContainer/Video/VideoPlayer
var _video_path : String = ""

var _last_called_file : Files

@onready var compose_button : Button = $Menu/FlowContainer/Compose

@onready var song_time_sample_text : TextEdit = $HBoxContainer/Left/VBoxContainer/SongTimeSample/SongTimeSampleText
@onready var video_time_sample_text : TextEdit = $HBoxContainer/Left/VBoxContainer/VideoTimeSample/VideoTimeSampleText
var last_valid_sample_song_text : String = ""
var last_valid_sample_video_text : String = ""
var time_regex := RegEx.new()

func _ready() -> void:
	get_tree().root.files_dropped.connect(_on_files_dropped)
	time_regex.compile("^\\d{2}:[0-5]\\d:\\d{3}$")
	Song.finished.connect(_on_song_finished)

func _on_files_dropped(files: PackedStringArray) -> void:
	var file = files[0]
	var drop_global_position = get_global_mouse_position()
	
	if song_button.get_global_rect().has_point(drop_global_position):
		set_song(file)
	elif icon_button.get_global_rect().has_point(drop_global_position):
		set_icon(file)
	elif image_button.get_global_rect().has_point(drop_global_position):
		set_image(file)
	elif video_button.get_global_rect().has_point(drop_global_position):
		set_video(file)

func _on_file_dialog_file_selected(path: String) -> void:
	match _last_called_file:
		Files.SONG:
			set_song(path)
		Files.ICON:
			set_icon(path)
		Files.IMAGE:
			set_image(path)
		Files.VIDEO:
			set_video(path)

func _pop_up_dialog(dialog : String) -> void:
	var duplicate_accept_dialog : AcceptDialog = accept_dialog.duplicate()
	duplicate_accept_dialog.dialog_text = dialog
	add_child(duplicate_accept_dialog)
	duplicate_accept_dialog.canceled.connect(duplicate_accept_dialog.queue_free)
	duplicate_accept_dialog.confirmed.connect(duplicate_accept_dialog.queue_free)
	duplicate_accept_dialog.popup()

func get_video_stream():
	if _video_path:
		return Loader.load_video_stream(_video_path)
	return null

func get_image_texture():
	if image_rect_texture:
		return image_rect_texture.texture
	return null

func set_song(path : String) -> void:
	if not path.get_extension() in VALID_AUDIO_EXTENSION:
		_pop_up_dialog("Só é aceito audios nos formatos " + str(VALID_AUDIO_EXTENSION))
		return
	
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var stream = Loader.load_music_stream(path)
	
	if stream is AudioStream:
		Song.set_song(stream)
		play_song_button.disabled = false
		compose_button.disabled = false
		song_time_sample_text.editable = true
		_song_path = path
		Editor.changed_editor()
	else:
		_pop_up_dialog("Não foi possível carregar o aúdio!")
		return

func set_icon(path : String) -> void:
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var image_texture : ImageTexture = Loader.load_image(path)
	
	if not image_texture:
		_pop_up_dialog("Tipo de arquivo inválido!")
		return
	else:
		icon_texture.texture = image_texture
		remove_icon_button.disabled = false
		_icon_path = path
		Editor.changed_editor()

func set_image(path : String) -> void:
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var image_texture : ImageTexture = Loader.load_image(path)
	
	if not image_texture:
		_pop_up_dialog("Tipo de arquivo inválido!")
		return
	else:
		image_rect_texture.texture = image_texture
		remove_image_button.disabled = false
		_image_path = path
		Editor.changed_editor()

func set_video(path : String) -> void:
	if path.get_extension() != "ogv":
		_pop_up_dialog("Só é aceito vídeos em formato \".ogv\"")
		return
	
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var stream = Loader.load_video_stream(path)
	
	if stream is VideoStream:
		video_player.stream = stream
		video_player.play()
		remove_video_button.disabled = false
		#video_time_sample_text.editable = true
		_video_path = path
		Editor.changed_editor()
	else:
		_pop_up_dialog("Não foi possível carregar o vídeo!")
		return

func _on_icon_button_pressed() -> void:
	file_dialog.popup()
	_last_called_file = Files.ICON

func _on_remove_button_pressed() -> void:
	icon_texture.texture = null
	remove_icon_button.disabled = true

func _on_video_button_pressed() -> void:
	file_dialog.popup()
	_last_called_file = Files.VIDEO

func _on_remove_video_button_pressed() -> void:
	video_player.stream = null
	remove_video_button.disabled = true
	video_time_sample_text.editable = false

func _on_image_button_pressed() -> void:
	file_dialog.popup()
	_last_called_file = Files.IMAGE

func _on_remove_image_button_pressed() -> void:
	image_rect_texture.texture = null
	remove_image_button.disabled = true

func _on_song_button_pressed() -> void:
	file_dialog.popup()
	_last_called_file = Files.SONG

func _on_play_song_button_pressed() -> void:
	if play_song_button.text == "Play":
		Song.play()
		play_song_button.text = "Stop"
	else:
		play_song_button.text = "Play"
		Song.stop()

func _on_song_finished() -> void:
	play_song_button.text = "Play"

func _on_compose_pressed() -> void:
	Song.BPM = get_BPM_value()
	Song.stop()
	Editor.change_to_composer()

func _on_song_time_sample_text_changed() -> void:
	if "\n" in song_time_sample_text.text:
		song_time_sample_text.text = song_time_sample_text.text.replace("\n", "")
		if time_regex.search(song_time_sample_text.text):
			last_valid_sample_song_text = song_time_sample_text.text
		else:
			song_time_sample_text.text = last_valid_sample_song_text
		song_time_sample_text.release_focus()

func _on_video_time_sample_text_changed() -> void:
	if "\n" in video_time_sample_text.text:
		video_time_sample_text.text = video_time_sample_text.text.replace("\n", "")
		if time_regex.search(video_time_sample_text.text):
			last_valid_sample_video_text = video_time_sample_text.text
		else:
			video_time_sample_text.text = last_valid_sample_video_text
		video_time_sample_text.release_focus()

func is_empty() -> bool:
	return $HBoxContainer/Left/VBoxContainer/Name/NameTextEdit.text.is_empty() and (
		$HBoxContainer/Left/VBoxContainer/Author/AuthorTextEdit.text.is_empty()) and (
		$HBoxContainer/Left/VBoxContainer/Track/TrackTextEdit.text.is_empty()) and (
		$HBoxContainer/Left/VBoxContainer/Creator/CreatorTextEdit.text.is_empty()) and (
		last_valid_sample_song_text.is_empty()) and last_valid_sample_video_text.is_empty() and (
		not Song.stream) and not icon_texture.texture and not image_rect_texture.texture and not video_player.stream

func reset() -> void:
	$HBoxContainer/Left/VBoxContainer/Name/NameTextEdit.text = ""
	$HBoxContainer/Left/VBoxContainer/Author/AuthorTextEdit.text = ""
	$HBoxContainer/Left/VBoxContainer/Track/TrackTextEdit.text = ""
	$HBoxContainer/Left/VBoxContainer/BPM/SpinBox.value = 60
	$HBoxContainer/Left/VBoxContainer/Creator/CreatorTextEdit.text = ""
	$HBoxContainer/Left/VBoxContainer/SongTimeSample/SongTimeSampleText.text = ""
	$HBoxContainer/Left/VBoxContainer/VideoTimeSample/VideoTimeSampleText.text = ""
	compose_button.disabled = true
	
	play_song_button.disabled = true
	Song.stream = null
	_song_path = ""
	
	remove_icon_button.disabled = true
	icon_texture.texture = null
	_icon_path = ""
	
	remove_image_button.disabled = true
	image_rect_texture.texture = null
	_image_path = ""
	
	remove_video_button.disabled = true
	video_player.stream = null
	_video_path = ""
	
	$HBoxContainer/Left/VBoxContainer/SongTimeSample/SongTimeSampleText.editable = false
	$HBoxContainer/Left/VBoxContainer/VideoTimeSample/VideoTimeSampleText.editable = false

@warning_ignore("shadowed_variable")
func load_editor(song : String, author : String, track : String, BPM : int, creator : String, song_time_sample : String, video_time_sample : String, 
	song_path : String, icon_path : String, image_path : String, video_path : String) -> void:
	
	reset()
	$HBoxContainer/Left/VBoxContainer/Name/NameTextEdit.text = song
	$HBoxContainer/Left/VBoxContainer/Author/AuthorTextEdit.text = author
	$HBoxContainer/Left/VBoxContainer/Track/TrackTextEdit.text = track
	$HBoxContainer/Left/VBoxContainer/BPM/SpinBox.value = BPM
	$HBoxContainer/Left/VBoxContainer/Creator/CreatorTextEdit.text = creator
	$HBoxContainer/Left/VBoxContainer/SongTimeSample/SongTimeSampleText.text = song_time_sample
	$HBoxContainer/Left/VBoxContainer/VideoTimeSample/VideoTimeSampleText.text = video_time_sample
	
	last_valid_sample_song_text = song_time_sample
	last_valid_sample_video_text = video_time_sample
	
	if song_path:
		set_song(song_path)
	
	if icon_path:
		set_icon(icon_path)
	
	if image_path:
		set_image(image_path)
	
	if video_path:
		set_video(video_path)

func get_song_name() -> String:
	return $HBoxContainer/Left/VBoxContainer/Name/NameTextEdit.text

func get_author_name() -> String:
	return $HBoxContainer/Left/VBoxContainer/Author/AuthorTextEdit.text

func get_track_name() -> String:
	return $HBoxContainer/Left/VBoxContainer/Track/TrackTextEdit.text

func get_BPM_value() -> int:
	return $HBoxContainer/Left/VBoxContainer/BPM/SpinBox.value

func get_creator_name() -> String:
	return $HBoxContainer/Left/VBoxContainer/Creator/CreatorTextEdit.text

func get_song_time_sample() -> String:
	return $HBoxContainer/Left/VBoxContainer/SongTimeSample/SongTimeSampleText.text

func get_video_time_sample() -> String:
	return $HBoxContainer/Left/VBoxContainer/VideoTimeSample/VideoTimeSampleText.text

func get_song_path() -> String:
	return _song_path

func get_icon_path() -> String:
	return _icon_path

func get_image_path() -> String:
	return _image_path

func get_video_path() -> String:
	return _video_path

func _on_spin_box_value_changed(value: float) -> void:
	Song.BPM = roundi(value)
	Editor.changed_editor()

func is_valid_for_export() -> String:
	if get_song_name().is_empty():
		return "The \"song\" name can't be empty."
	elif get_author_name().is_empty():
		return "The \"author\" name can't be empty."
	elif get_track_name().is_empty():
		return "The \"track\" name can't be empty."
	elif Song.stream == null:
		return "The \"song\" can't be empty."
	elif last_valid_sample_song_text.is_empty():
		return "The \"sample song time\" can't be empty."
	elif Global.text_to_time(last_valid_sample_song_text) >= Song.get_duration():
		return "The \"sample song time\" can't be equal or higher than the song duration."
	#elif video_player.stream != null:
		#if last_valid_sample_video_text.is_empty():
			#return "The \"sample video time\" can't be empty."
		#elif Global.text_to_time(last_valid_sample_video_text) >= video_player.get_stream_length(): ##NOTE CURRENTLY NOT SUPPORTED IN GODOT
			#return "The \"sample video time\" can't be equal or higher than the video duration."
			##NOTE CURRENTLY NOT SUPPORTED IN GODOT, THE FOLLOWING LINK HAS AN ADDON
			## NOTE https://www.youtube.com/watch?v=C9ptuhAB3GI&ab_channel=Voylin%27sGameDevJourney
	return ""

func _on_name_text_edit_text_changed(_new_text: String) -> void:
	Editor.changed_editor()

func _on_author_text_edit_text_changed(_new_text: String) -> void:
	Editor.changed_editor()

func _on_track_text_edit_text_changed(_new_text: String) -> void:
	Editor.changed_editor()

func _on_creator_text_edit_text_changed(_new_text: String) -> void:
	Editor.changed_editor()

func _on_visibility_changed() -> void:
	if not video_player or not video_player.stream:
		return
	if visible and _video_path:
		set_video(_video_path)
		video_player.play()
	else:
		video_player.stream = null
