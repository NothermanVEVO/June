extends MarginContainer

class_name ActionsContainer

const MINIMUM_SIZE_Y : float = 60
const Y_LIMIT : float = 200

var is_resizing : bool = false
var mouse_position_when_down : Vector2
var start_minimum_size_y : float

@onready var _actions_container : ActionsContainer = $"."

@onready var _title_rich_text_label : RichTextLabel = $VBoxContainer/TopContainer/TitleRichTextLabel
@onready var _add_action_path_button : Button = $VBoxContainer/TopContainer/AddActionPathButton
@onready var _close_button : Button = $VBoxContainer/TopContainer/CloseButton

@onready var _actions_vbox_container : ActionsVBoxContainer = $VBoxContainer/ScrollContainer/CenterContainer/ActionsVBoxContainer

func _ready() -> void:
	set_process(false)

func setup(pathway_editor : PathwayEditor, highest_grid_time : float) -> void:
	_actions_vbox_container.setup(pathway_editor, highest_grid_time)

func _process(delta: float) -> void:
	if is_resizing:
		custom_minimum_size.y = clampf(start_minimum_size_y + (mouse_position_when_down.y - get_global_mouse_position().y), 0, get_viewport_rect().size.y - Y_LIMIT)

func _on_resize_button_button_up() -> void:
	is_resizing = false
	set_process(false)

func _on_resize_button_button_down() -> void:
	if not _close_button.button_pressed:
		return
	is_resizing = true
	mouse_position_when_down = get_global_mouse_position()
	start_minimum_size_y = custom_minimum_size.y
	set_process(true)

func _on_close_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_close_button.text = "Fechar editor de ações"
		_title_rich_text_label.visible = true
		_add_action_path_button.visible = true
		_actions_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		custom_minimum_size.y = 300
	else:
		_close_button.text = "Abrir editor de ações"
		_title_rich_text_label.visible = false
		_add_action_path_button.visible = false
		_actions_container.size_flags_horizontal = Control.SIZE_SHRINK_END
		custom_minimum_size.y = 0
