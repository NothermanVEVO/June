extends AutoTarget

class_name Trap

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.TRAP_TEXTURE

func collide() -> void:
	print("tomei dano da trap")
