extends VBoxContainer

class_name SettingsEditor

enum Files{SONG = 0, ICON = 1, IMAGE = 2, VIDEO = 3}

@onready var file_dialog : FileDialog = $FileDialog
@onready var accept_dialog : AcceptDialog = $AcceptDialog

const DRAG_N_DROP_TEXT : String = "Select file or Drag and Drop here"
const VALID_AUDIO_EXTENSION : Array[String] = ["wav", "mp3", "ogg", "flac"]

@onready var song_button : Button = $HBoxContainer/Right/VBoxContainer/Song/SongButton
@onready var play_song_button : Button = $HBoxContainer/Right/VBoxContainer/Song/PlaySongButton
@onready var song : AudioStreamPlayer = $HBoxContainer/Right/VBoxContainer/Song/AudioStreamPlayer
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

func _ready() -> void:
	get_tree().root.files_dropped.connect(_on_files_dropped)

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
	accept_dialog.dialog_text = dialog
	accept_dialog.popup()

func set_song(path : String) -> void:
	if not path.get_extension() in VALID_AUDIO_EXTENSION:
		_pop_up_dialog("Só é aceito audios nos formatos " + str(VALID_AUDIO_EXTENSION))
		return
	
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var stream = load(path)
	
	if stream is AudioStream:
		song.stream = stream
		play_song_button.disabled = false
		compose_button.disabled = false
	else:
		_pop_up_dialog("Não foi possível carregar o aúdio!")
		return

func set_icon(path : String) -> void:
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var image := Image.new()
	var error = image.load(path)
	
	if error != OK:
		_pop_up_dialog("Tipo de arquivo inválido!")
		return
	else:
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		icon_texture.texture = image_texture
		remove_icon_button.disabled = false

func set_image(path : String) -> void:
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var image := Image.new()
	var error = image.load(path)
	
	if error != OK:
		_pop_up_dialog("Tipo de arquivo inválido!")
		return
	else:
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		image_rect_texture.texture = image_texture
		remove_image_button.disabled = false

func set_video(path : String) -> void:
	if path.get_extension() != "ogv":
		_pop_up_dialog("Só é aceito vídeos em formato \".ogv\"")
		return
	
	if not FileAccess.file_exists(path):
		_pop_up_dialog("Não foi possível achar o arquivo: \"" + path + "\"")
		return
	
	var stream = load(path)
	
	if stream is VideoStream:
		video_player.stream = stream
		video_player.play()
		remove_video_button.disabled = false
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
		song.play()
		play_song_button.text = "Stop"
	else:
		play_song_button.text = "Play"
		song.stop()

func _on_audio_stream_player_finished() -> void:
	play_song_button.text = "Play"
