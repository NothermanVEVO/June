extends AutoTarget

class_name Heart

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditor.HEART_TEXTURE

func collide() -> void:
	print("ganhei vida")
