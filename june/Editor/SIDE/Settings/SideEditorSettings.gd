extends VBoxContainer

@onready var file_dialog : FileDialog = $FileDialog
@onready var file_dialog_save: FileDialog = $FileDialogSave

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

@onready var song_sample_slider: HSlider = $First/Right/VBoxContainer/SongTimeSample/SongSampleSlider
@onready var song_sample_test_button: Button = $First/Right/VBoxContainer/SongTimeSample/SongSampleTestButton

var song_sample_tween : Tween
var _song_sample_test_id : int = 0

enum DialogChoice{SAVE, EXPORT, SONG, ICON, BANNER}

var _last_dialog_choice : DialogChoice

func _ready() -> void:
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
	
	if not SideEditor.changed_current_song_map.is_connected(_ready):
		SideEditor.changed_current_song_map.connect(_ready)

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

func _on_offset_spin_box_value_changed(value: float) -> void:
	SideEditor.current_editor_save.song_offset = value

func _on_bpm_spin_box_value_changed(value: float) -> void:
	SideEditor.current_editor_save.BPM = int(value)

func _on_choose_song_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.SONG
	file_dialog.popup_file_dialog()

func _on_icon_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.ICON
	file_dialog.popup_file_dialog()

func _on_image_button_pressed() -> void:
	_last_dialog_choice = DialogChoice.BANNER
	file_dialog.popup_file_dialog()

func _on_file_dialog_file_selected(path: String) -> void:
	if _last_dialog_choice == DialogChoice.SONG:
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
			
	elif _last_dialog_choice == DialogChoice.SAVE:
		SideEditor.save_file(path)

func _on_compose_pressed() -> void:
	get_tree().change_scene_to_packed(_editor_composer_scene)

func _on_file_id_pressed(id: int) -> void:
	match file.get_item_text(id):
		"Novo":
			SideEditor.new_file()
		"Abrir":
			file_dialog_save.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			file_dialog_save.popup_file_dialog()
		"Salvar":
			if SideEditor.get_file_path():
				SideEditor.save_file(SideEditor.get_file_path())
				return
			
			_last_dialog_choice = DialogChoice.SAVE
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.popup_file_dialog()
		"Exportar":
			_last_dialog_choice = DialogChoice.EXPORT
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			file_dialog.popup_file_dialog()
		"Abrir Pasta":
			OS.shell_open(ProjectSettings.globalize_path(Global.SIDE_EDITOR_PATH))

func _on_file_dialog_save_file_selected(path: String) -> void:
	SideEditor.open_file(path)

func _config_music() -> void:
	if not Song.stream:
		compose.disabled = true
		play_song_button.disabled = true
		return
	
	compose.disabled = false
	play_song_button.disabled = false
	

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
	pass # Replace with function body.
