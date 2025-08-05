extends ItemList

const MINIMUM_SIZE_X : float = 25.0 # It's inside the GameComponentsList too, needs to adjust that value

var is_resizing : bool = false
var mouse_position_when_down : Vector2
var start_minimum_size_x : float

@onready var game_components := $"../Game Components List"

func _process(delta: float) -> void:
	if is_resizing:
		custom_minimum_size.x = start_minimum_size_x - (mouse_position_when_down.x - get_global_mouse_position().x)
		custom_minimum_size.x = MINIMUM_SIZE_X if custom_minimum_size.x < MINIMUM_SIZE_X else custom_minimum_size.x
		var max_pos = game_components.position.x - MINIMUM_SIZE_X
		if custom_minimum_size.x > max_pos:
			game_components.custom_minimum_size.x = get_viewport_rect().size.x - custom_minimum_size.x - MINIMUM_SIZE_X
			if game_components.position.x > get_viewport_rect().size.x - MINIMUM_SIZE_X * 2:
				game_components.custom_minimum_size.x = MINIMUM_SIZE_X
				custom_minimum_size.x = get_viewport_rect().size.x - MINIMUM_SIZE_X * 2

func _on_resize_button_down() -> void:
	is_resizing = true
	mouse_position_when_down = get_global_mouse_position()
	start_minimum_size_x = custom_minimum_size.x
	set_process(true)

func _on_resize_button_up() -> void:
	is_resizing = false
	set_process(false)

func _on_close_button_pressed() -> void:
	if custom_minimum_size.x == MINIMUM_SIZE_X:
		custom_minimum_size.x = 200
		if custom_minimum_size.x > game_components.position.x:
			custom_minimum_size.x = game_components.position.x - MINIMUM_SIZE_X
	else:
		custom_minimum_size.x = MINIMUM_SIZE_X
