extends ManualTarget

class_name HoldManual

var _end_time : float

var _has_hitted : bool

var _middle_hold : NinePatchRect = NinePatchRect.new()
var _end_hold : Sprite2D = Sprite2D.new()

var left_edit_button : Button
var right_edit_button : Button

signal is_pressing_left_edit_button(hold_target : HoldManual)
signal is_pressing_right_edit_button(hold_target : HoldManual)
signal released_left_edit_button
signal released_right_edit_button

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	_end_time = end_time
	set_start_time(start_time)
	set_path_type(path_type)
	
	texture = SideEditor.START_HOLD_TEXTURE
	
	add_child(_middle_hold)
	_middle_hold.z_index = z_index - 1
	_middle_hold.texture = SideEditor.MIDDLE_HOLD_TEXTURE
	
	add_child(_end_hold)
	_end_hold.z_index = z_index - 1
	_end_hold.texture = SideEditor.END_HOLD_TEXTURE
	
	_middle_hold.patch_margin_left = 6
	_middle_hold.patch_margin_top = 6
	_middle_hold.patch_margin_right = 6
	_middle_hold.patch_margin_bottom = 6

func _ready() -> void:
	set_process(false)

func _process(_delta: float) -> void:
	if left_edit_button and left_edit_button.button_pressed:
		is_pressing_left_edit_button.emit(self)
	if right_edit_button and right_edit_button.button_pressed:
		is_pressing_right_edit_button.emit(self)

func hit() -> void:
	print("ai")
	_has_hitted = true

func released() -> void:
	_death()

func _death() -> void:
	print("morri")

func is_colliding(time : float) -> bool:
	return not _has_hitted and (time >= get_start_time() - get_collision_radius_in_time()
			or time <= get_start_time() + get_collision_radius_in_time())

func get_global_rect() -> Rect2:
	if texture:
		return Rect2(global_position.x - texture.get_width() / 2, global_position.y - texture.get_height() / 2, texture.get_width(), texture.get_height()).merge(_middle_hold.get_global_rect()).merge(Rect2(_end_hold.global_position.x - _end_hold.texture.get_width() / 2, _end_hold.global_position.y - _end_hold.texture.get_height() / 2, _end_hold.texture.get_width(), _end_hold.texture.get_height()))
	else:
		return Rect2(global_position.x, global_position.y, 0, 0)

func set_current_speed(speed : float) -> void:
	super.set_current_speed(speed)
	set_end_time(_end_time)

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	set_end_time(_end_time)

func get_end_time() -> float:
	return _end_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time
	
	var end_pos = Path.get_pos_x(0, get_width_in_secs_by_speed(), end_time - _start_time, Path.hitzone, Path.width) - Path.hitzone
	
	while end_time - _start_time > get_width_in_secs_by_speed():
		end_time -= get_width_in_secs_by_speed()
		end_pos += Path.get_pos_x(0, get_width_in_secs_by_speed(), end_time - _start_time, Path.hitzone, Path.width) - Path.hitzone
	
	_end_hold.position = Vector2(end_pos, 0)
	
	_middle_hold.size = Vector2(end_pos, Path.HEIGHT * 0.7)
	_middle_hold.position = Vector2(0, -_middle_hold.size.y / 2)
	
	_update_edit_buttons_positions()

func get_duration() -> float:
	return _end_time - _start_time

func has_hitted() -> bool:
	return _has_hitted

func create_edit_buttons() -> void:
	if left_edit_button:
		left_edit_button.queue_free()
	if right_edit_button:
		right_edit_button.queue_free()
	
	left_edit_button = Button.new()
	right_edit_button = Button.new()
	
	add_child(left_edit_button)
	add_child(right_edit_button)
	
	left_edit_button.button_up.connect(_left_edit_button_released)
	right_edit_button.button_up.connect(_right_edit_button_released)
	
	left_edit_button.mouse_default_cursor_shape = Control.CURSOR_HSPLIT
	right_edit_button.mouse_default_cursor_shape = Control.CURSOR_HSPLIT
	
	if not texture:
		return
	
	var size := texture.get_size()
	size.x = size.x / 2
	
	left_edit_button.size = size
	right_edit_button.size = size
	
	_update_edit_buttons_positions()

func _update_edit_buttons_positions() -> void:
	if not left_edit_button or not right_edit_button:
		return
	
	left_edit_button.position.x = -left_edit_button.size.x
	left_edit_button.position.y = -left_edit_button.size.y / 2
	
	right_edit_button.position.x = _end_hold.position.x# + _end_hold.get_rect().size.x
	right_edit_button.position.y = -_end_hold.get_rect().size.y / 2

@warning_ignore("shadowed_variable_base_class")
func set_edit_buttons_visibility(visible : bool) -> void:
	if left_edit_button:
		left_edit_button.visible = visible
	if right_edit_button:
		right_edit_button.visible = visible

func _left_edit_button_released() -> void:
	released_left_edit_button.emit()

func _right_edit_button_released() -> void:
	released_right_edit_button.emit()
