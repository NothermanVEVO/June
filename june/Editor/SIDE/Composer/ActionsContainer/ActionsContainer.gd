extends MarginContainer

class_name ActionsContainer

const _ACTION_PATH_CONTAINER_SCENE : PackedScene = preload("res://Editor/SIDE/Composer/ActionsContainer/ActionPathContainer/ActionPathContainer.tscn")

## RESIZE VARS

const _MINIMUM_SIZE_Y : float = 60
const _Y_LIMIT : float = 200

var _is_resizing : bool = false
var _mouse_position_when_down : Vector2
var _start_minimum_size_y : float
var _last_size_y_before_close : float = 300

var _actions_paths_containers : Array[ActionPathContainer] = []

## ONREADY THINGS

@onready var _actions_container : ActionsContainer = $"."

@onready var _title_rich_text_label : RichTextLabel = $VBoxContainer/TopContainer/TitleRichTextLabel
@onready var _add_action_path_button : Button = $VBoxContainer/TopContainer/AddActionPathButton
@onready var _close_button : Button = $VBoxContainer/TopContainer/CloseButton

@onready var _actions_vbox_container : ActionsVBoxContainer = $VBoxContainer/ScrollContainer/CenterContainer/HBoxContainer/ActionsVBoxContainer

@onready var _action_list_margin_container : MarginContainer = $VBoxContainer/ScrollContainer/CenterContainer/HBoxContainer/ActionListMarginContainer

var _pathway_editor : PathwayEditor

signal changed_actions_path_order

func _ready() -> void:
	set_process(false)

func setup(pathway_editor : PathwayEditor, highest_grid_time : float) -> void:
	_pathway_editor = pathway_editor
	_actions_vbox_container.setup(pathway_editor, highest_grid_time, _actions_paths_containers)

func _process(delta: float) -> void:
	if _is_resizing:
		custom_minimum_size.y = clampf(_start_minimum_size_y + (_mouse_position_when_down.y - get_global_mouse_position().y), 0, get_viewport_rect().size.y - _Y_LIMIT)

func _on_resize_button_button_up() -> void:
	_is_resizing = false
	set_process(false)

func _on_resize_button_button_down() -> void:
	if not _close_button.button_pressed:
		return
	_is_resizing = true
	_mouse_position_when_down = get_global_mouse_position()
	_start_minimum_size_y = custom_minimum_size.y
	set_process(true)

func _on_close_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_close_button.text = "Fechar editor de ações"
		_title_rich_text_label.visible = true
		_add_action_path_button.visible = true
		_actions_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_minimum_size.y = _last_size_y_before_close
		_action_list_margin_container.custom_minimum_size.x = 200
	else:
		_close_button.text = "Abrir editor de ações"
		_title_rich_text_label.visible = false
		_add_action_path_button.visible = false
		_actions_container.size_flags_horizontal = Control.SIZE_SHRINK_END
		_last_size_y_before_close = custom_minimum_size.y
		custom_minimum_size.y = 0
		_action_list_margin_container.custom_minimum_size.x = 0

func _on_add_action_path_button_pressed() -> void:
	var action_path_container : ActionPathContainer = _ACTION_PATH_CONTAINER_SCENE.instantiate()
	_actions_vbox_container.add_child(action_path_container)
	_actions_vbox_container.move_child(action_path_container, 0)
	_actions_paths_containers.append(action_path_container)
	
	action_path_container.get_path_editor().set_speed(_pathway_editor.get_speed())
	
	_update_all_action_path_container_indexes()
	
	action_path_container.request_to_erase.connect(_requested_to_erase)
	action_path_container.request_to_move_up.connect(_requested_to_move_up)
	action_path_container.request_to_move_down.connect(_requested_to_move_down)

func _requested_to_erase(action_path_container : ActionPathContainer) -> void:
	_actions_vbox_container.remove_child(action_path_container)
	_actions_paths_containers.erase(action_path_container)
	action_path_container.queue_free()
	
	_update_all_action_path_container_indexes()

func _requested_to_move_up(action_path_container : ActionPathContainer) -> void:
	if get_action_vbox_container_actions_count() <= 1:
		return
	
	var index := action_path_container.index - 1
	var to_index : int = index if index >= 0 else _actions_paths_containers.size() - 1
	
	_actions_vbox_container.move_child(action_path_container, to_index)
	_update_all_action_path_container_indexes()

func _requested_to_move_down(action_path_container : ActionPathContainer) -> void:
	if get_action_vbox_container_actions_count() <= 1:
		return
	
	var index := action_path_container.index + 1
	var to_index : int = index if index < _actions_paths_containers.size() else 0
	
	_actions_vbox_container.move_child(action_path_container, to_index)
	_update_all_action_path_container_indexes()

func get_action_vbox_container_actions_count() -> int:
	var i := 0
	
	for child in _actions_vbox_container.get_children():
		if child is ActionPathContainer:
			i += 1
	
	return i

func _update_all_action_path_container_indexes() -> void:
	var index : int = 0
	var children := _actions_vbox_container.get_children()
	for i in _actions_vbox_container.get_child_count():
		if children[i] is ActionPathContainer:
			children[i].update_index_text(index)
			index += 1
	
	changed_actions_path_order.emit()

func is_resizing() -> bool:
	return _is_resizing
