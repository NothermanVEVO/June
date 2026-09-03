extends TargetResource

class_name RealCloneResource

@export var fake_clones : Array[FakeCloneResource] = []

func _init(start_time : float = 0.0, path_type : int = 0, fake_clones : Array[FakeCloneResource] = []) -> void:
	super._init(start_time, path_type)
	self.fake_clones = fake_clones
