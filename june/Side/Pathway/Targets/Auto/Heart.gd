extends AutoTarget

class_name Heart

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.HEART_TEXTURE

func collide(character : Character) -> void:
	print("ganhei vida")
