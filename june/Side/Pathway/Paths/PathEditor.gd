extends Path

class_name PathEditor

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, - HEIGHT / 2, width, HEIGHT), Color.WHITE, false, 1, true)
	
	draw_line(Vector2(hitzone, -HEIGHT / 2), Vector2(hitzone, HEIGHT / 2), Color.YELLOW, 10)
