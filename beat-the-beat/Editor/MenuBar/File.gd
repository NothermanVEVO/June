extends PopupMenu

class_name FileMenu

enum Choices {NEW = 0, OPEN = 1, SAVE = 2, EXPORT = 3}
var _last_choice : Choices

@export var confirmation_dialog : ConfirmationDialog

func _ready() -> void:
	index_pressed.connect(_file_index_pressed)
	confirmation_dialog.confirmed.connect(_confirmation_dialog_confirmed)

func _file_index_pressed(index : int) -> void:
	match index:
		Choices.NEW:
			new_file()
		Choices.OPEN:
			pass
		Choices.SAVE:
			save_file()
		Choices.EXPORT:
			pass

func _confirmation_dialog_confirmed() -> void:
	match _last_choice:
		Choices.NEW:
			Editor.editor_menu_bar.reset_editor()
		Choices.OPEN:
			pass
		Choices.SAVE:
			pass
		Choices.EXPORT:
			pass

func new_file() -> void:
	if Editor.editor_menu_bar.is_editor_empty():
		return
	confirmation_dialog.dialog_text = "Do you want to create a new file?"
	confirmation_dialog.ok_button_text = "Yes"
	_last_choice = Choices.NEW
	confirmation_dialog.popup()

func open_file() -> void:
	pass

func save_file() -> void:
	if Editor.editor_settings.is_empty():
		return
	
