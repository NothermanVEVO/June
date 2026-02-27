extends PanelContainer

class_name FakeClonesContainer

const _FAKE_CLONE_CONTAINER_SCENE : PackedScene = preload("res://Editor/SIDE/Composer/TargetInfoWindow/FakeCloneContainer.tscn")

@onready var _vbox_container : VBoxContainer = $MarginContainer/VBoxContainer

var _real_clone : RealClone
var _pathway_editor : PathwayEditor

func setup(real_clone : RealClone, pathway_editor : PathwayEditor) -> void:
	_real_clone = real_clone
	_pathway_editor = pathway_editor
	
	for i in _real_clone.fake_clones.size():
		_add_fake_clone(_real_clone.fake_clones[i], i)

func _add_fake_clone(fake_clone : FakeClone, idx : int) -> void:
	var fake_clone_container : FakeCloneContainer = _FAKE_CLONE_CONTAINER_SCENE.instantiate()
	_vbox_container.add_child(fake_clone_container)
	fake_clone_container.set_fake_clone(fake_clone, idx)

func _on_add_fake_clone_button_pressed() -> void:
	var fake_clone := FakeClone.new(0, Path.Types.GROUND)
	fake_clone.create_target_editor()
	var _real_clone_last_path_type := _real_clone.get_path_type()
	_real_clone.add_new_fake_clone(fake_clone)
	_add_fake_clone(fake_clone, _real_clone.fake_clones.size() - 1)
	
	_pathway_editor.remove_target_at(_real_clone_last_path_type, _real_clone, true)
	_pathway_editor.add_target_at(_real_clone.get_path_type(), _real_clone, true)
	_pathway_editor.add_target_at(fake_clone.get_path_type(), fake_clone, true)
