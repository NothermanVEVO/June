extends Tap

class_name HammerTap

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.HAMMER_TEXTURE

func set_path_type(path_type : Path.Types) -> void:
	super.set_path_type(path_type)
	if path_type == Path.Types.GROUND:
		flip_v = true
