extends PopupMenu

class_name FileMenu

@export var _editor_scene : Editor.Scenes

enum Choices {NEW = 0, OPEN = 1, SAVE = 2, EXPORT = 3, QUIT = 4, NONE = 5}
var _last_choice : Choices = Choices.NONE

static var current_ID : String = ""

static var _last_file_dialog_choice : Choices

static var _file_path : String = ""

static var called_for_save : Node

static var dialog_confirmation_id : int
static var dialog_file_id : int

static var _last_saved_id : int = -1

static var _quit_on_save_id : int = -1

func _ready() -> void:
	current_ID = Global.get_UUID()
	
	index_pressed.connect(_file_index_pressed)
	DialogConfirmation.confirmed.connect(_confirmation_dialog_confirmed)
	DialogConfirmation.custom_action.connect(_confirmation_dialog_canceled)
	
	#file_dialog.access = FileDialog.ACCESS_USERDATA
	#file_dialog.root_subfolder = Global.EDITOR_PATH
	#file_dialog.use_native_dialog = true
	#
	#add_child(file_dialog)
	DialogFile.file_selected.connect(_file_dialog_file)
	_file_path = ""
	Global.set_window_title(Global.TitleType.EDITOR_UNSAVED)

func _process(_delta: float) -> void:
	if not Editor.editor_settings.visible and not Editor.editor_composer.visible:
		return
	if Input.is_action_just_pressed("Save") and not DialogConfirmation.visible and Editor.get_current_scene() == _editor_scene:
		if _file_path:
			save_file(_file_path)
		else:
			save()

func _file_index_pressed(index : int) -> void:
	match index:
		Choices.NEW:
			new_file()
		Choices.OPEN:
			open_file()
		Choices.SAVE:
			if _file_path:
				save_file(_file_path)
			else:
				save()
		Choices.EXPORT:
			export_file()
		Choices.QUIT:
			if Editor.editor_composer and Editor.editor_composer.editor_menu_bar and Editor.editor_composer.editor_menu_bar.game and Editor.editor_composer.editor_menu_bar.game._copied_notes: ## AVOIDS MEMORY LEAK
				for note in Editor.editor_composer.editor_menu_bar.game._copied_notes:
					note.queue_free()
			_quit()

func _confirmation_dialog_confirmed() -> void:
	if DialogConfirmation.get_last_caller() != dialog_confirmation_id:
		return
	match _last_choice:
		Choices.NEW:
			Editor.editor_composer.editor_menu_bar.reset()
			Editor.editor_settings.reset()
			Editor.editor_composer.visible = false
			Editor.editor_settings.visible = true
			_file_path = ""
			current_ID = Global.get_UUID()
			Global.set_window_title(Global.TitleType.EDITOR_UNSAVED)
			Editor.saved_file()
		Choices.QUIT:
			if _file_path:
				save_file(_file_path)
				Editor.is_on_editor = false
				get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
			else:
				_quit_on_save_id = save()

func _confirmation_dialog_canceled(custom_action : StringName) -> void:
	if DialogConfirmation.get_last_caller() != dialog_confirmation_id:
		return
	match _last_choice:
		Choices.QUIT:
			Editor.is_on_editor = false
			get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)

func new_file() -> void:
	if EditorMenuBar.is_editor_empty() and Editor.editor_settings.is_empty():
		return
	_pop_confirmation_dialog("Você quer criar um novo arquivo?", "Yes", Choices.NEW)

func open_file() -> void:
	dialog_file_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_USERDATA, Global.EDITOR_PATH)
	_last_file_dialog_choice = Choices.OPEN

func _open_file(path : String) -> void:
	if not FileAccess.file_exists(_file_path):
		_pop_confirmation_dialog("Esse arquivo não existe!", "Ok", Choices.NONE)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var result = json.parse(content)
	if result == OK:
		var json_data = json.get_data()
		var validate_wrong = SongResource.validate_dictionary(json_data)
		if validate_wrong:
			_pop_confirmation_dialog(validate_wrong, "Ok", Choices.NONE)
		else:
			var song_resource := SongResource.dictionary_to_resource(json_data)
			current_ID = song_resource.ID
			Editor.load_resource(SongResource.dictionary_to_resource(json_data))
			Editor.saved_file()
	else:
		_pop_confirmation_dialog("Ocorreu um erro ao tentar ler o arquivo.", "Ok", Choices.NONE)

static func save_file(path : String, song_res : SongResource = null) -> void:
	if not Editor.editor_settings.is_empty():
		if path:
			var song_resource : SongResource
			if song_res:
				song_resource = song_res
				song_resource.ID = Global.get_UUID()
			else:
				song_resource = Editor.to_resource()
				song_resource.ID = current_ID
			for s_map in song_resource.song_maps:
				for note in s_map.notes:
					note.is_selected = false
				for long_note in s_map.long_notes:
					long_note.is_selected = false
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file:
				var json_string := JSON.stringify(song_resource.get_dictionary(), "\t")
				file.store_string(json_string)
				file.close()
				DialogConfirmation.pop_up("Cancelar", "Ok", "O arquivo foi salvo com sucesso!")
				Editor.saved_file()
			else:
				DialogConfirmation.pop_up("Cancelar", "Ok", "Ocorreu um erro ao tentar salvar o arquivo.")

static func save() -> int:
	if Editor.editor_settings.is_empty() and EditorMenuBar.is_editor_empty():
		return -1
	if not _file_path:
		dialog_file_id = DialogFile.pop_up(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_USERDATA, Global.EDITOR_PATH)
		_last_file_dialog_choice = Choices.SAVE
	return dialog_file_id

func _export(path : String) -> void:
	path = path.get_basename()
	if DirAccess.dir_exists_absolute(path):
		_pop_confirmation_dialog("Esse nome já existe.", "Ok", Choices.NONE)
		return
	else:
		var error = DirAccess.make_dir_absolute(path)
		if error == OK:
			if _file_path:
				save_file(_file_path)
			var song_resource := Editor.to_resource()
			if song_resource.song:
				song_resource.song = path + "//song." + Editor.editor_settings.get_song_path().get_extension()
			if song_resource.video:
				song_resource.video = path + "//video." + Editor.editor_settings.get_video_path().get_extension()
			if song_resource.icon:
				song_resource.icon = path + "//icon." + Editor.editor_settings.get_icon_path().get_extension()
			if song_resource.image:
				song_resource.image = path + "//image." + Editor.editor_settings.get_image_path().get_extension()
			save_file(path + "//song_map.json", song_resource)
			_export_song(path)
			_export_video(path)
			_export_icon(path)
			_export_image(path)
			_pop_confirmation_dialog("O Song Map foi exportado com sucesso.", "Ok", Choices.NONE)
		else:
			_pop_confirmation_dialog("Ocorreu um erro ao tentar criar o Song Map.", "Ok", Choices.NONE)
	pass

func export_file() -> void:
	var is_settings_valid := Editor.editor_settings.is_valid_for_export()
	if is_settings_valid:
		_pop_confirmation_dialog(is_settings_valid, "Ok", Choices.NONE)
		return
		
	var is_composer_valid := Editor.editor_composer.editor_menu_bar.is_valid_for_export()
	if is_composer_valid:
		_pop_confirmation_dialog(is_composer_valid, "Ok", Choices.NONE)
		return
	#file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog_file_id = DialogFile.pop_up(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_USERDATA, Global.SONGS_PATH)
	_last_file_dialog_choice = Choices.EXPORT

func _export_song(path : String) -> void:
	if not Editor.editor_settings.get_song_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_song_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Não foi possível abrir o arquivo de música.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_song_path(), path + "//song." + Editor.editor_settings.get_song_path().get_extension())

func _export_video(path : String) -> void:
	if not Editor.editor_settings.get_video_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_video_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Não foi possível abrir o arquivo de video.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_video_path(), path + "//video." + Editor.editor_settings.get_video_path().get_extension())

func _export_icon(path : String) -> void:
	if not Editor.editor_settings.get_icon_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_icon_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Não foi possível abrir o arquivo do ícone.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_icon_path(), path + "//icon." + Editor.editor_settings.get_icon_path().get_extension())

func _export_image(path : String) -> void:
	if not Editor.editor_settings.get_image_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_image_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Não foi possível abrir o arquivo de imagem.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_image_path(), path + "//image." + Editor.editor_settings.get_image_path().get_extension())

func _quit() -> void:
	if Song.stream:
		Song.stop()
	if not Editor.is_saved():
		_pop_confirmation_dialog("Você deseja salvar antes de sair?", "Salvar e sair", Choices.QUIT, "Sair sem salvar")
	else:
		Editor.is_on_editor = false
		get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)

func _pop_confirmation_dialog(dialog_text : String, ok_button_text : String, choice : Choices, custom_button_text : String = "", cancel_text : String = "Cancelar") -> void:
	dialog_confirmation_id = DialogConfirmation.pop_up(cancel_text, ok_button_text, dialog_text, custom_button_text)
	_last_choice = choice

func _file_dialog_file(path : String) -> void:
	if DialogFile.get_last_caller() != dialog_file_id:
		return
	_last_saved_id = dialog_file_id
	DialogFile.remove_last_caller()
	if _last_file_dialog_choice == Choices.SAVE:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file() + ".json"
		save_file(_file_path)
		if _quit_on_save_id == dialog_file_id:
			Editor.is_on_editor = false
			get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
	elif  _last_file_dialog_choice == Choices.OPEN:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file()
		_open_file(_file_path)
	elif _last_file_dialog_choice == Choices.EXPORT:
		_export(Global.SONGS_PATH + "//" + path.get_file() + "")

static func get_file_path() -> String:
	return _file_path

static func get_last_saved_id() -> int:
	return _last_saved_id
