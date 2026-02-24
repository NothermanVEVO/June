extends Tap

class_name RealClone

var fake_clones : Array[FakeClone] = []

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditor.CLONE_FINAL_TEXTURE
