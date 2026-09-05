extends Tap

class_name FakeClone

var real_clone : RealClone

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.CLONE_TEXTURE
