extends Target

class_name AutoTarget

func is_colliding(time : float) -> bool:
	return (time >= get_start_time() - get_collision_radius_in_time()
			or time <= get_start_time() + get_collision_radius_in_time())
