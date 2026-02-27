extends Target

class_name AutoTarget

func is_colliding(time : float) -> bool:
	return (time >= get_start_time() - get_collision_radius_in_time()
			or time <= get_start_time() + get_collision_radius_in_time())

func get_global_rect() -> Rect2:
	return Rect2(global_position.x - texture.get_size().x / 2, global_position.y - texture.get_size().y / 2, texture.get_size().x, texture.get_size().y)
