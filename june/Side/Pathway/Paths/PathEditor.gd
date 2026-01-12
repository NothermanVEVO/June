extends Path

class_name PathEditor

func _process(delta: float) -> void:
	queue_redraw()
	_display_targets(Song.get_time())

func _draw() -> void:
	draw_rect(Rect2(0, - HEIGHT / 2, width, HEIGHT), Color.WHITE, false, 1, true)
	
	draw_line(Vector2(hitzone, -HEIGHT / 2), Vector2(hitzone, HEIGHT / 2), Color.YELLOW, 10)

func _display_targets(time : float) -> void:
	var targets := get_targets(time - (WIDTH_IN_SECS_BY_SPEED() / 4), time + WIDTH_IN_SECS_BY_SPEED() + (WIDTH_IN_SECS_BY_SPEED() / 4))
	
	for target in _last_visible_targets:
		if not target in targets:
			target.visible = false
	_last_visible_targets.clear()
	
	for target in targets:
		#if not target.visible:
			#continue
		target.visible = true
		_last_visible_targets.append(target)
		
		target.position.x = get_pos_x(time, time + WIDTH_IN_SECS_BY_SPEED(), target.get_start_time(), hitzone, width)
		
		if target.get_start_time() < time:
			var p_time = time
			var difference = get_pos_x(target.get_start_time(), target.get_start_time() + WIDTH_IN_SECS_BY_SPEED(), p_time, hitzone, width) - hitzone
			while p_time - WIDTH_IN_SECS_BY_SPEED() > 0.0:
				p_time -= WIDTH_IN_SECS_BY_SPEED()
				difference -= get_pos_x(target.get_start_time(), target.get_start_time() + WIDTH_IN_SECS_BY_SPEED(), p_time, hitzone, width) - hitzone
			target.position.x -= difference
		elif target.get_start_time() > time + WIDTH_IN_SECS_BY_SPEED():
			var p_time = target.get_start_time() - (time + WIDTH_IN_SECS_BY_SPEED())
			var difference = get_pos_x(0, WIDTH_IN_SECS_BY_SPEED(), p_time, 0, width)
			while p_time > WIDTH_IN_SECS_BY_SPEED():
				p_time -= WIDTH_IN_SECS_BY_SPEED()
				difference -= get_pos_x(0, WIDTH_IN_SECS_BY_SPEED(), p_time, 0, width)
			target.position.x += difference
