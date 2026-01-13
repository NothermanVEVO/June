extends ManualTarget

class_name Hold

var _end_time : float

var _has_hitted : bool

var _middle_hold : NinePatchRect = NinePatchRect.new()
var _end_hold : Sprite2D = Sprite2D.new()

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	_end_time = end_time
	set_start_time(start_time)
	set_path_type(path_type)
	
	texture = SideEditor.START_HOLD_TEXTURE
	
	add_child(_middle_hold)
	_middle_hold.z_index = z_index - 1
	_middle_hold.texture = SideEditor.MIDDLE_HOLD_TEXTURE
	
	add_child(_end_hold)
	_end_hold.texture = SideEditor.END_HOLD_TEXTURE
	
	_middle_hold.patch_margin_left = 6
	_middle_hold.patch_margin_top = 6
	_middle_hold.patch_margin_right = 6
	_middle_hold.patch_margin_bottom = 6

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

func get_duration() -> float:
	return _end_time - _start_time

func has_hitted() -> bool:
	return _has_hitted
