extends MarginContainer

class_name ActionPathContainer

@onready var _index_line_edit : LineEdit = $HBoxContainer/IndexLineEdit

signal request_to_erase(action_path_container : ActionPathContainer)
signal request_to_move_up(action_path_container : ActionPathContainer)
signal request_to_move_down(action_path_container : ActionPathContainer)

var _patch_action : PathAction

var index : int

func _init(path_editor : PathAction = null) -> void:
	if path_editor:
		_patch_action = path_editor
	else:
		_patch_action = PathAction.new(Path.Types.AIR, Pathway.Direction.RIGHT)

func _ready() -> void:
	if _patch_action:
		add_child(_patch_action)

func get_middle_y() -> float:
	return position.y + (get_rect().size.y / 2)

func update_index_text(idx : int) -> void:
	index = idx
	var text := _index_line_edit.text.strip_edges()
	if text.is_empty() or text.is_valid_int():
		_index_line_edit.text = str(index)
	
	for target in _patch_action.get_manual_targets(0, Song.get_duration()):
		target.path_index = index

func add_manual_target(manual_target : ManualTarget) -> void:
	if manual_target is ManualTargetAction or manual_target is ManualTargetActionHold:
		manual_target.path_index = index
		_patch_action.add_manual_target(manual_target)

func get_path_editor() -> PathAction:
	return _patch_action

func _on_erase_button_pressed() -> void:
	request_to_erase.emit(self)

func _on_move_up_button_pressed() -> void:
	request_to_move_up.emit(self)

func _on_move_down_button_pressed() -> void:
	request_to_move_down.emit(self)

func _on_index_line_edit_text_submitted(_new_text: String) -> void:
	update_index_text(index)
