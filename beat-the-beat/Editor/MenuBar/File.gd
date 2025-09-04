extends PopupMenu

class_name FileMenu

enum Choices {NEW = 0, OPEN = 1, SAVE = 2, EXPORT = 3, NONE = 4}
var _last_choice : Choices

@export var confirmation_dialog : ConfirmationDialog

static var current_ID : String = ""

var file_dialog := FileDialog.new()
var _last_file_dialog_choice : Choices

static var _file_path : String = ""

func _ready() -> void:
	current_ID = Global.get_UUID()
	
	index_pressed.connect(_file_index_pressed)
	confirmation_dialog.confirmed.connect(_confirmation_dialog_confirmed)
	
	file_dialog.access = FileDialog.ACCESS_USERDATA
	file_dialog.root_subfolder = Global.EDITOR_PATH
	file_dialog.use_native_dialog = true
	
	add_child(file_dialog)
	file_dialog.file_selected.connect(_file_dialog_file)

func _file_index_pressed(index : int) -> void:
	match index:
		Choices.NEW:
			new_file()
		Choices.OPEN:
			open_file()
		Choices.SAVE:
			save_file()
		Choices.EXPORT:
			pass

func _confirmation_dialog_confirmed() -> void:
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
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_last_file_dialog_choice = Choices.OPEN
	file_dialog.popup()

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
			Editor.load_resource(SongResource.dictionary_to_resource(json_data))
	else:
		_pop_confirmation_dialog("An error occured when trying to read the file.", "Ok", Choices.NONE)

func save_file() -> void:
	if not Editor.editor_settings.is_empty():
		if _file_path:
			var song_resource := Editor.to_resource()
			for s_map in song_resource.song_maps:
				for note in s_map.notes:
					note.is_selected = false
				for long_note in s_map.long_notes:
					long_note.is_selected = false
			song_resource.ID = current_ID
			var file := FileAccess.open(_file_path, FileAccess.WRITE)
			if file:
				var json_string := JSON.stringify(song_resource.get_dictionary(), "\t")
				file.store_string(json_string)
				file.close()
				Global.set_window_title(Global.TitleType.EDITOR_SAVED)
				_pop_confirmation_dialog("The file was saved with success!", "Ok", Choices.NONE)
			else:
				_pop_confirmation_dialog("An error occured while saving the file.", "Ok", Choices.NONE)
		else:
			file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
			_last_file_dialog_choice = Choices.SAVE
			file_dialog.popup()

func _pop_confirmation_dialog(dialog_text : String, ok_button_text : String, choice : Choices) -> void:
	confirmation_dialog.dialog_text = dialog_text
	confirmation_dialog.ok_button_text = ok_button_text
	_last_choice = choice
	confirmation_dialog.popup()

func _file_dialog_file(path : String) -> void:
	if _last_file_dialog_choice == Choices.SAVE:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file() + ".json"
		save_file()
	elif  _last_file_dialog_choice == Choices.OPEN:
		_file_path = Global.EDITOR_PATH + "//" + path.get_file()
		_open_file(_file_path)

static func get_file_path() -> String:
	return _file_path
