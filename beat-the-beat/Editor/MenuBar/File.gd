extends PopupMenu

class_name FileMenu

enum Choices {NEW = 0, OPEN = 1, SAVE = 2, EXPORT = 3, NONE = 4}
var _last_choice : Choices = Choices.NONE

static var current_ID : String = ""

static var _last_file_dialog_choice : Choices

static var _file_path : String = ""

static var called_for_save : Node

static var dialog_confirmation_id : int
static var dialog_file_id : int

func _ready() -> void:
	current_ID = Global.get_UUID()
	
	index_pressed.connect(_file_index_pressed)
	DialogConfirmation.confirmed.connect(_confirmation_dialog_confirmed)
	
	#file_dialog.access = FileDialog.ACCESS_USERDATA
	#file_dialog.root_subfolder = Global.EDITOR_PATH
	#file_dialog.use_native_dialog = true
	#
	#add_child(file_dialog)
	DialogFile.file_selected.connect(_file_dialog_file)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Save") and not DialogConfirmation.visible:
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
		Choices.OPEN:
			pass
		Choices.SAVE:
			pass
		Choices.EXPORT:
			pass
		Choices.NONE:
			pass

func new_file() -> void:
	if EditorMenuBar.is_editor_empty() and Editor.editor_settings.is_empty():
		return
	_pop_confirmation_dialog("Do you want to create a new file?", "Yes", Choices.NEW)

func open_file() -> void:
	dialog_file_id = DialogFile.pop_up(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_USERDATA, Global.EDITOR_PATH)
	_last_file_dialog_choice = Choices.OPEN

func _open_file(path : String) -> void:
	if not FileAccess.file_exists(_file_path):
		_pop_confirmation_dialog("The file doesn't exists!", "Ok", Choices.NONE)
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
			Global.set_window_title(Global.TitleType.EDITOR_SAVED)
			var song_resource := SongResource.dictionary_to_resource(json_data)
			current_ID = song_resource.ID
			Editor.load_resource(SongResource.dictionary_to_resource(json_data))
			Editor.saved_file()
	else:
		_pop_confirmation_dialog("An error occured when trying to read the file.", "Ok", Choices.NONE)

static func save_file(path : String) -> void:
	if not Editor.editor_settings.is_empty():
		if path:
			var song_resource := Editor.to_resource()
			for s_map in song_resource.song_maps:
				for note in s_map.notes:
					note.is_selected = false
				for long_note in s_map.long_notes:
					long_note.is_selected = false
			song_resource.ID = current_ID
			var file := FileAccess.open(path, FileAccess.WRITE)
			if file:
				var json_string := JSON.stringify(song_resource.get_dictionary(), "\t")
				file.store_string(json_string)
				file.close()
				Global.set_window_title(Global.TitleType.EDITOR_SAVED)
				DialogConfirmation.pop_up("Cancel", "Ok", "The file was saved with success!")
				Editor.saved_file()
			else:
				DialogConfirmation.pop_up("Cancel", "Ok", "An error occured while saving the file.")

static func save() -> void:
	if Editor.editor_settings.is_empty() and Editor.editor_composer.editor_menu_bar.is_editor_empty():
		return
	if not _file_path:
		dialog_file_id = DialogFile.pop_up(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_USERDATA, Global.EDITOR_PATH)
		_last_file_dialog_choice = Choices.SAVE

func _export(path : String) -> void:
	path = path.get_basename()
	if DirAccess.dir_exists_absolute(path):
		_pop_confirmation_dialog("This name already exists.", "Ok", Choices.NONE)
		return
	else:
		var error = DirAccess.make_dir_absolute(path)
		if error == OK:
			_export_song(path)
			_export_video(path)
			_export_icon(path)
			_export_image(path)
			_pop_confirmation_dialog("Song map exported successfully!", "Ok", Choices.NONE)
		else:
			_pop_confirmation_dialog("An error occured while trying to create the folder.", "Ok", Choices.NONE)
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
		_pop_confirmation_dialog("Wasn't possible to open the song file.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_song_path(), path + "//song." + Editor.editor_settings.get_song_path().get_extension())

func _export_video(path : String) -> void:
	if not Editor.editor_settings.get_video_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_video_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Wasn't possible to open the video file.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_video_path(), path + "//video." + Editor.editor_settings.get_video_path().get_extension())

func _export_icon(path : String) -> void:
	if not Editor.editor_settings.get_icon_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_icon_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Wasn't possible to open the icon file.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_icon_path(), path + "//icon." + Editor.editor_settings.get_icon_path().get_extension())

func _export_image(path : String) -> void:
	if not Editor.editor_settings.get_image_path():
		return
	var file := FileAccess.open(Editor.editor_settings.get_image_path(), FileAccess.READ)
	if not file:
		_pop_confirmation_dialog("Wasn't possible to open the image file.", "Ok", Choices.NONE)
		return
	DirAccess.copy_absolute(Editor.editor_settings.get_image_path(), path + "//video." + Editor.editor_settings.get_image_path().get_extension())

func _pop_confirmation_dialog(dialog_text : String, ok_button_text : String, choice : Choices) -> void:
	dialog_confirmation_id = DialogConfirmation.pop_up("Cancel", ok_button_text, dialog_text)
	_last_choice = choice

func _file_dialog_file(path : String) -> void:
	if DialogFile.get_last_caller() != dialog_file_id:
		return
	DialogFile.remove_last_caller()
	if _last_file_dialog_choice == Choices.SAVE:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file() + ".json"
		save_file(_file_path)
	elif  _last_file_dialog_choice == Choices.OPEN:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file()
		_open_file(_file_path)
	elif _last_file_dialog_choice == Choices.EXPORT:
		_export(Global.SONGS_PATH + "//" + path.get_file() + "")

static func get_file_path() -> String:
	return _file_path
