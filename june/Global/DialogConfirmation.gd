extends ConfirmationDialog

var _last_caller : int
var _id : int = 0

var custom_button : Button

func _ready() -> void:
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	force_native = true
	custom_button = add_button("Cancelar", true, "Hide")
	canceled.connect(_canceled)
	custom_action.connect(_custom_action)

func pop_up(cancel_text : String, ok_text : String, dialog : String, custom_button_text : String = "") -> int:
	_id += 1
	_last_caller = _id
	cancel_button_text = cancel_text
	ok_button_text = ok_text
	dialog_text = dialog
	if custom_button_text:
		custom_button.visible = true
		custom_button.text = custom_button_text
	else:
		custom_button.visible = false
	reset_size()
	popup()
	return _id

func get_last_caller() -> int:
	return _last_caller

func remove_last_caller() -> void:
	_last_caller = -1

func _canceled() -> void:
	hide()
	remove_last_caller()

func _custom_action(_action : StringName) -> void:
	_canceled.call_deferred()
