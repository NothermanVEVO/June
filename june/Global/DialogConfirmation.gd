extends ConfirmationDialog

var _last_caller : int
var _id : int = 0

func _ready() -> void:
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	force_native = true

func pop_up(cancel_text : String, ok_text : String, dialog : String) -> int:
	_id += 1
	_last_caller = _id
	cancel_button_text = cancel_text
	ok_button_text = ok_text
	dialog_text = dialog
	reset_size()
	popup()
	return _id

func get_last_caller() -> int:
	return _last_caller

func remove_last_caller() -> void:
	_last_caller = -1
