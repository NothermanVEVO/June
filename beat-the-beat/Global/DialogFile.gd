extends FileDialog

var _last_caller : int
var _id : int = 0

func _ready() -> void:
	initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	force_native = true
	use_native_dialog = true

func pop_up(mode_file : FileMode, dialog_access : Access, root : String = "") -> int:
	_id += 1
	_last_caller = _id
	file_mode = mode_file
	access = dialog_access
	root_subfolder = root
	popup()
	return _id

func get_last_caller() -> int:
	return _last_caller

func remove_last_caller() -> void:
	_last_caller = -1
