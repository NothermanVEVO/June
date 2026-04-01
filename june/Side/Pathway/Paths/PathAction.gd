extends PathEditor

class_name PathAction

func add_manual_target(manual_target : ManualTarget) -> void:
	super.add_manual_target(manual_target)

func _draw() -> void:
	var height := get_rect().size.y / 2
	draw_rect(Rect2(2, 2, width, height), Color.WHITE, false, 1, true)
	
	#draw_line(Vector2(hitzone, -height / 2), Vector2(hitzone, height / 2), Color.YELLOW, 10)
