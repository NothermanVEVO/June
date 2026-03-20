extends MarginContainer

class_name ActionPathContainer

@onready var _index_line_edit : LineEdit = $HBoxContainer/IndexLineEdit

signal request_to_erase(action_path_container : ActionPathContainer)
signal request_to_move_up(action_path_container : ActionPathContainer)
signal request_to_move_down(action_path_container : ActionPathContainer)

var _path_editor : PathAction

func _init(path_editor : PathAction = null) -> void:
	if path_editor:
		_path_editor = path_editor
	else:
		_path_editor = PathAction.new(Path.Types.AIR, Pathway.Direction.RIGHT)

func _ready() -> void:
	if _path_editor:
		add_child(_path_editor)

func get_middle_y() -> float:
	return position.y + (get_rect().size.y / 2)

func update_index_text() -> void:
	var text := _index_line_edit.text.strip_edges()
	if text.is_empty() or text.is_valid_int():
		_index_line_edit.text = str(get_index())

func get_path_editor() -> PathAction:
	return _path_editor

func _on_erase_button_pressed() -> void:
	request_to_erase.emit(self)

func _on_move_up_button_pressed() -> void:
	request_to_move_up.emit(self)

func _on_move_down_button_pressed() -> void:
	request_to_move_down.emit(self)

func _on_index_line_edit_text_submitted(_new_text: String) -> void:
	update_index_text()
