extends Action

class_name HoldAction

var hold : Hold

func _init(start_time : float, end_time : float, path_type : Path.Types) -> void:
	hold = Hold.new(start_time, end_time, path_type)

func _ready() -> void:
	add_child(hold)

func hit() -> void:
	hold.hit()

func released() -> void:
	hold.released()

func _death() -> void:
	hold._death()

func is_colliding(time : float) -> bool:
	return hold.is_colliding(time)

func get_global_rect() -> Rect2:
	return hold.get_global_rect()

func set_current_speed(speed : float) -> void:
	hold.set_current_speed(speed)

func set_start_time(start_time : float) -> void:
	hold.set_start_time(start_time)

func get_end_time() -> float:
	return hold.get_end_time()

func set_end_time(end_time : float) -> void:
	hold.set_end_time(end_time)

func get_duration() -> float:
	return hold.get_duration()

func has_hitted() -> bool:
	return hold.has_hitted()

func create_edit_buttons() -> void:
	hold.create_edit_buttons()

func set_edit_buttons_visibility(visible : bool) -> void:
	hold.set_edit_buttons_visibility(visible)
