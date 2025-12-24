extends PanelContainer

class_name LongNoteInfo

@onready var _annotation_container : FlowContainer = $MarginContainer/VBoxContainer/Annotation
@onready var _section_container : FlowContainer = $MarginContainer/VBoxContainer/Section
@onready var _speed_container : FlowContainer = $MarginContainer/VBoxContainer/Speed
@onready var _fade_container : VBoxContainer = $MarginContainer/VBoxContainer/Fade

@onready var _annotation_text : TextEdit = $MarginContainer/VBoxContainer/Annotation/NoteText
@onready var _section_text : TextEdit = $MarginContainer/VBoxContainer/Section/SectionText
@onready var _speed_spin_box : SpinBox = $MarginContainer/VBoxContainer/Speed/SpeedSpinBox
@onready var _fade_check_button : CheckButton = $MarginContainer/VBoxContainer/Fade/FadeCheckButton

@export var _type : LongNote.Type

signal annotation_value_changed
signal section_value_changed
signal speed_value_changed
signal fade_value_changed

func set_type(type : LongNote.Type) -> void:
	_type = type

func _ready() -> void:
	_annotation_container.visible = false
	_section_container.visible = false
	_speed_container.visible = false
	_fade_container.visible = false
	match _type:
		LongNote.Type.ANNOTATION:
			_annotation_container.visible = true
		LongNote.Type.SECTION:
			_section_container.visible = true
		LongNote.Type.SPEED:
			_speed_container.visible = true
		LongNote.Type.FADE:
			_fade_container.visible = true
	
	z_index = 2

func _process(_delta: float) -> void:
	if visible and (Input.is_action_just_pressed("Add Item") or Input.is_action_just_pressed("Inspect Note")) and not get_global_rect().has_point(get_global_mouse_position()):
		visible = false

@warning_ignore("shadowed_variable")
func display(display : bool) -> void:
	visible = display

func set_annotation(note : String) -> void:
	_annotation_text.text = note

func set_section(text : String) -> void:
	_section_text.text = text

func set_speed(speed : float) -> void:
	_speed_spin_box.value = speed

func set_fade(value : bool) -> void:
	_fade_check_button.button_pressed = value

func get_annotation() -> String:
	return _annotation_text.text

func get_section() -> String:
	return _section_text.text

func get_speed() -> float:
	return _speed_spin_box.value

func get_fade() -> bool:
	return _fade_check_button.button_pressed

func _on_speed_spin_box_value_changed(_value: float) -> void:
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

func _on_fade_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_fade_check_button.text = "Fade In"
	else:
		_fade_check_button.text = "Fade Out"
	_fade_check_button.release_focus()
	fade_value_changed.emit()
