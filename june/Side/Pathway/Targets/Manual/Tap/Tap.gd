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
