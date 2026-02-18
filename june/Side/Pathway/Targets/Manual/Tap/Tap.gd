extends ManualTarget

class_name Tap

func hit() -> void:
	print("ai")
	_death()

func _death() -> void:
	print("morri")

func is_colliding(time : float) -> bool:
	return (time >= get_start_time() - get_collision_radius_in_time()
			or time <= get_start_time() + get_collision_radius_in_time())

func get_global_rect() -> Rect2:
	if texture:
		return Rect2(global_position.x - texture.get_width() / 2, global_position.y - texture.get_height() / 2, texture.get_width(), texture.get_height())
	else:
		return Rect2(global_position.x, global_position.y, 0, 0)
