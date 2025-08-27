extends PanelContainer

class_name LongNoteInfo

@onready var annotation_container : FlowContainer = $MarginContainer/VBoxContainer/Annotation
@onready var section_container : FlowContainer = $MarginContainer/VBoxContainer/Section
@onready var speed_container : FlowContainer = $MarginContainer/VBoxContainer/Speed

@onready var _annotation_text : TextEdit = $MarginContainer/VBoxContainer/Annotation/NoteText
@onready var _section_text : TextEdit = $MarginContainer/VBoxContainer/Section/SectionText
@onready var _speed_spin_box : SpinBox = $MarginContainer/VBoxContainer/Speed/SpeedSpinBox

var _type : LongNote.Type

signal annotation_value_changed
signal section_value_changed
signal speed_value_changed

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
	
	z_index = 2

func _process(delta: float) -> void:
	if visible and (Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")) and not get_global_rect().has_point(get_global_mouse_position()):
		visible = false

func display(display : bool) -> void:
	visible = display

func set_annotation(note : String) -> void:
	_annotation_text.text = note

func set_section(name : String) -> void:
	_section_text.text = name

func set_speed(speed : float) -> void:
	_speed_spin_box.value = speed

func get_annotation() -> String:
	return _annotation_text.text

func get_section() -> String:
	return _section_text.text

func get_speed() -> float:
	return _speed_spin_box.value

func _on_speed_spin_box_value_changed(value: float) -> void:
	speed_value_changed.emit()
	_speed_spin_box.release_focus()

func _on_note_text_changed() -> void:
	if "\n" in _annotation_text.text:
		_annotation_text.text = _annotation_text.text.replace("\n", "")
		_annotation_text.release_focus()
	annotation_value_changed.emit()

func _on_section_text_changed() -> void:
	if "\n" in _section_text.text:
		_section_text.text = _section_text.text.replace("\n", "")
		_section_text.release_focus()
	section_value_changed.emit()
