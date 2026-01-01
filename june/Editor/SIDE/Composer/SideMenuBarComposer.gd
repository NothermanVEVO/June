extends FlowContainer

class_name SideMenuBarComposer

enum Grids {ONE = 1, TWO = 2, FOUR = 4, EIGHT = 8, TWELVE = 12, SIXTEEN = 16}

static var _current_grid : int = 1
@onready var _grid_option_button : OptionButton = $Right/Grid

static var _zoom_value : float = 1.0

static func get_divisor() -> float:
	return 60.0 / Song.BPM / _current_grid

func get_selected_grid() -> int:
	return _current_grid

static func get_zoom_value() -> float:
	return _zoom_value

func _on_grid_item_selected(index: int) -> void:
	_current_grid = _grid_option_button.get_item_id(index)

func _on_zoom_value_changed(value: float) -> void:
	_zoom_value = value
