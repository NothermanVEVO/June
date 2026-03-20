extends PathEditor

class_name PathAction

func add_manual_target(manual_target : ManualTarget) -> void:
	super.add_manual_target(manual_target)
	manual_target.position.y += (get_rect().size.y / 4) + 2 ## WHY 2?? I DON'T KNOW, AND I'M NOT GONNA STRESS WITH IT FOR NOW
	manual_target.scale *= 1.5

func _draw() -> void:
	var height := get_rect().size.y / 2
	draw_rect(Rect2(2, 2, width, height), Color.WHITE, false, 1, true)
	
	#draw_line(Vector2(hitzone, -height / 2), Vector2(hitzone, height / 2), Color.YELLOW, 10)
