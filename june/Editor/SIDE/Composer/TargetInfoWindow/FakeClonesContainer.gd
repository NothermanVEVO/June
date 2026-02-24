extends PanelContainer

class_name FakeClonesContainer

const _FAKE_CLONE_CONTAINER_SCENE : PackedScene = preload("res://Editor/SIDE/Composer/TargetInfoWindow/FakeCloneContainer.tscn")

var _fake_clones : Array[FakeClone] = []

func set_fake_clones(fake_clones : Array[FakeClone]) -> void:
	_fake_clones = fake_clones
	
	for i in fake_clones.size():
		_add_fake_clone(fake_clones[i], i)

func _add_fake_clone(fake_clone : FakeClone, idx : int) -> void:
	var fake_clone_container : FakeCloneContainer = _FAKE_CLONE_CONTAINER_SCENE.instantiate()
	add_child(fake_clone_container)
	fake_clone_container.set_fake_clone(fake_clone, idx)

func _on_add_fake_clone_button_pressed() -> void:
	#_add_fake_clone()
	pass
