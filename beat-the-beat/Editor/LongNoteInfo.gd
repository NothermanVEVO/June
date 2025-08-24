extends PanelContainer

class_name LongNoteInfo

@onready var annotation_container : FlowContainer = $MarginContainer/VBoxContainer/Annotation
@onready var section_container : FlowContainer = $MarginContainer/VBoxContainer/Section
@onready var speed_container : FlowContainer = $MarginContainer/VBoxContainer/Speed

var _type : LongNote.Type

func set_type(type : LongNote.Type) -> void:
	_type = type

func _ready() -> void:
	annotation_container.visible = false
	section_container.visible = false
	speed_container.visible = false
	match _type:
		LongNote.Type.ANNOTATION:
			annotation_container.visible = true
		LongNote.Type.SECTION:
			section_container.visible = true
		LongNote.Type.SPEED:
			speed_container.visible = true

func _process(delta: float) -> void:
	if visible and (Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")) and not get_global_rect().has_point(get_global_mouse_position()):
		visible = false

func display(display : bool) -> void:
	visible = display
