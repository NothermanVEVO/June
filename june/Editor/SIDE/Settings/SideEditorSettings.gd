extends VBoxContainer
#
#@onready var file_dialog : FileDialog = $FileDialog
#@onready var file_dialog_save: FileDialog = $FileDialogSave

@onready var song_name_line_edit: LineEdit = $First/Left/VBoxContainer/Name/SongNameLineEdit
@onready var song_author_line_edit: LineEdit = $First/Left/VBoxContainer/Author/SongAuthorLineEdit
@onready var collection_line_edit: LineEdit = $First/Left/VBoxContainer/Collection/CollectionLineEdit
@onready var map_creator_line_edit: LineEdit = $First/Left/VBoxContainer/Creator/MapCreatorLineEdit
@onready var offset_spin_box: SpinBox = $First/Right/VBoxContainer/Offset/OffsetSpinBox
@onready var bpm_spin_box: SpinBox = $First/Right/VBoxContainer/BPM/BPMSpinBox

@onready var icon_texture: TextureRect = $Second/Left2/VBoxContainer/Icon/IconTexture
@onready var banner_texture: TextureRect = $Second/Left2/VBoxContainer/Banner/BannerTexture

@onready var play_song_button: Button = $First/Right/VBoxContainer/Song/PlaySongButton

@onready var compose: Button = $MenuBar/Compose

@onready var file: PopupMenu = $MenuBar/MenuBar/File

@onready var _editor_composer_scene : PackedScene = load("res://Editor/SIDE/Composer/SideEditorComposer.tscn")

@onready var song_time_sample_text: TextEdit = $First/Right/VBoxContainer/SongTimeSample/SongTimeSampleText
@onready var song_sample_slider: HSlider = $First/Right/VBoxContainer/SongTimeSample/SongSampleSlider
@onready var song_sample_test_button: Button = $First/Right/VBoxContainer/SongTimeSample/SongSampleTestButton

var song_sample_tween : Tween
var _song_sample_test_id : int = 0

enum DialogChoice{OPEN, SAVE, EXPORT, SONG, ICON, BANNER}

var _last_dialog_choice : DialogChoice
var _last_dialog_id : int = -1

func _ready() -> void:
	SideEditor.changed_current_song_map.connect(_load_editor_save)
	
	DialogFile.file_selected.connect(_dialog_file_file_selected)
	
	_load_editor_save()

func _load_editor_save() -> void:
	var editor_save : SideEditorResource = SideEditor.current_editor_save
	
	if not editor_save:
		return
	
	song_name_line_edit.text = editor_save.song_name
	song_author_line_edit.text = editor_save.song_author
	collection_line_edit.text = editor_save.collection
	map_creator_line_edit.text = editor_save.map_creator
	offset_spin_box.value = editor_save.song_offset
	bpm_spin_box.value = editor_save.BPM
	
	if editor_save.song_stream:
		Song.set_song(editor_save.song_stream)
		_config_music()
	
	if editor_save.banner_texture:
		banner_texture.texture = editor_save.banner_texture
	if editor_save.icon_texture:
		icon_texture.texture = editor_save.icon_texture
	
	if editor_save.banner_texture:
		banner_texture.texture = editor_save.banner_texture
	if editor_save.icon_texture:
		icon_texture.texture = editor_save.icon_texture

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("Save") and SideEditor.get_file_path():
		SideEditor.save_file(SideEditor.get_file_path())

func _on_song_name_line_edit_text_changed(new_text: String) -> void:
	SideEditor.current_editor_save.song_name = new_text

func _on_song_author_line_edit_text_changed(new_text: String) -> void:
	SideEditor.current_editor_save.song_author = new_text

func _on_collection_line_edit_text_changed(new_text: String) -> void:
	SideEditor.current_editor_save.collection = new_text

func _on_map_creator_line_edit_text_changed(new_text: String) -> void:
	SideEditor.current_editor_save.map_creator = new_text

func _on_song_sample_slider_value_changed(value: float) -> void:
	SideEditor.current_editor_save.song_sample_time = value
	
	if value == 0.0:
		song_time_sample_text.text = "00:00:000"
		return
	song_time_sample_text.text = Global.time_to_text(Song.get_duration() * value / 100)

func _on_offset_spin_box_value_changed(value: float) -> void:
	SideEditor.current_editor_save.song_offset = value
	Song.offset = value

func _on_bpm_spin_box_value_changed(value: float) -> void:
	SideEditor.current_editor_save.BPM = int(value)
	Song.BPM = int(value)

func _on_choose_song_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.SONG
	_last_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM)

func _on_icon_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.ICON
	_last_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM)

func _on_image_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.BANNER
	_last_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM)

func _on_compose_pressed() -> void:
	get_tree().change_scene_to_packed(_editor_composer_scene)

func _on_file_id_pressed(id: int) -> void:
	match file.get_item_text(id):
		"Novo":
			SideEditor.new_file(true)
		"Abrir":
			_last_dialog_choice = DialogChoice.OPEN
			_last_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_USERDATA, Global.SIDE_EDITOR_PATH)
		"Salvar":
			if SideEditor.get_file_path():
				SideEditor.save_file(SideEditor.get_file_path())
				return
			
			_last_dialog_choice = DialogChoice.SAVE
			_last_dialog_id = DialogFile.pop_up(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_USERDATA, Global.SIDE_EDITOR_PATH)
		#"Exportar":
			#_last_dialog_choice = DialogChoice.EXPORT
			#file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			#file_dialog.popup_file_dialog()
		"Abrir Pasta":
			OS.shell_open(ProjectSettings.globalize_path(Global.SIDE_EDITOR_PATH))

func _dialog_file_file_selected(path: String) -> void:
	if DialogFile.get_last_caller() != _last_dialog_id:
		return
	
	DialogFile.remove_last_caller()
	
	if _last_dialog_choice == DialogChoice.OPEN:
		SideEditor.open_file(path)
	elif _last_dialog_choice == DialogChoice.SAVE:
		SideEditor.save_file(path + ".tres")
	elif _last_dialog_choice == DialogChoice.SONG:
		var music_stream := Loader.load_music_stream(path)
	
		if not music_stream:
			return
	
		Song.set_song(music_stream)
		_config_music()
		SideEditor.current_editor_save.song_stream = music_stream
	elif _last_dialog_choice == DialogChoice.ICON or _last_dialog_choice == DialogChoice.BANNER:
		var image_texture := Loader.load_image(path)
		
		if not image_texture:
			return
		
		if _last_dialog_choice == DialogChoice.ICON:
			icon_texture.texture = image_texture
			SideEditor.current_editor_save.icon_texture = image_texture
		elif _last_dialog_choice == DialogChoice.BANNER:
			banner_texture.texture = image_texture
			SideEditor.current_editor_save.banner_texture = image_texture

func _config_music() -> void:
	if not Song.stream:
		compose.disabled = true
		song_sample_test_button.disabled = true
		play_song_button.disabled = true
		song_sample_slider.editable = false
		return
	
	compose.disabled = false
	song_sample_test_button.disabled = false
	song_sample_slider.editable = true
	play_song_button.disabled = false
	
	if SideEditor.current_editor_save:
		song_sample_slider.value = SideEditor.current_editor_save.song_sample_time
	
	_set_time_sample_slider_max()

func _set_time_sample_slider_max() -> void:
	if Song.get_duration() < Song.TIME_SAMPLE:
		song_sample_slider.editable = false
		return
	
	var y : float = (Song.get_duration() - Song.TIME_SAMPLE)
	
	song_sample_slider.max_value = y / Song.get_duration() * 100

func _play_sample_song() -> void:
	_song_sample_test_id += 1
	
	if play_song_button.text == "Parar":
		play_song_button.text = "Tocar"
	
	Song.play(Song.get_duration() * song_sample_slider.value / 100)
	
	Song.volume_db = -80.0
	
	song_sample_tween = get_tree().create_tween()
	song_sample_tween.tween_property(
		Song,
		"volume_db",
		0,
		Song.SAMPLE_FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	get_tree().create_timer(Song.TIME_SAMPLE - Song.SAMPLE_FADE_DURATION).timeout.connect(_start_song_sample_fade_out.bind(_song_sample_test_id))

func _start_song_sample_fade_out(song_sample_test_id : int) -> void:
	if _song_sample_test_id != song_sample_test_id:
		return
	song_sample_tween = get_tree().create_tween()
	song_sample_tween.tween_property(
		Song,
		"volume_db",
		-80.0,
		Song.SAMPLE_FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	song_sample_tween.finished.connect(_song_sample_tween_finished)

func _song_sample_tween_finished() -> void:
	Song.stop()
	Song.volume_db = 0
	song_sample_test_button.text = "Testar"

func _on_play_song_button_pressed() -> void:
	if play_song_button.text == "Tocar":
		if song_sample_test_button.text == "Parar":
			_song_sample_tween_finished()
		Song.play()
		_song_sample_test_id += 1
		play_song_button.text = "Parar"
	else:
		play_song_button.text = "Tocar"
		Song.stop()

func _on_song_sample_test_button_pressed() -> void:
	if song_sample_test_button.text == "Testar":
		song_sample_test_button.text = "Parar"
		_play_sample_song()
	elif song_sample_test_button.text == "Parar":
		song_sample_test_button.text = "Testar"
		_song_sample_tween_finished()
