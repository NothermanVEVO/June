extends Path

class_name PathEditor

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, - Path.HEIGHT / 2, Path.width, Path.HEIGHT), Color.WHITE, false, 1, true)
