extends ItemList

class_name SideGameComponents

const MINIMUM_SIZE_X : float = 25.0

var is_resizing : bool = false
var mouse_position_when_down : Vector2
var start_minimum_size_x : float

static var _width : float = 0.0

static var _selected_in_text : String = ""

signal resizing

func _process(delta: float) -> void:
	if is_resizing:
		custom_minimum_size.x = start_minimum_size_x + (mouse_position_when_down.x - get_global_mouse_position().x)
		custom_minimum_size.x = MINIMUM_SIZE_X if custom_minimum_size.x < MINIMUM_SIZE_X else custom_minimum_size.x
		var screen_difference_x := get_viewport_rect().size.x - custom_minimum_size.x
		if screen_difference_x < MINIMUM_SIZE_X:
				custom_minimum_size.x = get_viewport_rect().size.x - MINIMUM_SIZE_X
		resizing.emit()

static func get_width() -> float:
	return _width

static func get_selected_in_text() -> String:
	return _selected_in_text

func _on_resize_button_down() -> void:
	is_resizing = true
	mouse_position_when_down = get_global_mouse_position()
	start_minimum_size_x = custom_minimum_size.x
	set_process(true)

func _on_resize_button_up() -> void:
	is_resizing = false
	set_process(false)

func _on_resized() -> void:
	_width = custom_minimum_size.x

func _on_item_selected(index: int) -> void:
	_selected_in_text = get_item_text(index)
