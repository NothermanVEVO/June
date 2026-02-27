extends Window

class_name TargetInfoWindow

@onready var _target_name : RichTextLabel = $MarginContainer/ScrollContainer/VBoxContainer/TargetName

@onready var _start_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/StartTimeContainer
@onready var _start_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/StartTimeContainer/StartTimeLineEdit

@onready var _end_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/EndTimeContainer
@onready var _end_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/EndTimeContainer/EndTimeLineEdit

@onready var _path_type_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/PathTypeContainer
@onready var _path_type_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/PathTypeContainer/PathTypeLineEdit

@onready var _speed_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/SpeedContainer
@onready var _speed_spin_box : SpinBox = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/SpeedContainer/SpeedSpinBox

@onready var _half_reaction_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/HalfReactionContainer
@onready var _half_reaction_check_box : CheckBox = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/HalfReactionContainer/HalfReactionCheckBox

@onready var _delay_parent_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/DelayParentTimeContainer
@onready var _delay_parent_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/DelayParentTimeContainer/DelayParentLineEdit

@onready var _first_delay_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/FirstDelayTimeContainer
@onready var _first_delay_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/FirstDelayTimeContainer/FirstDelayLineEdit

@onready var _second_delay_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/SecondDelayTimeContainer
@onready var _second_delay_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/SecondDelayTimeContainer/SecondDelayLineEdit

@onready var _real_clone_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/RealCloneTimeContainer
@onready var _real_clone_time_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/RealCloneTimeContainer/RealCloneLineEdit

@onready var _fake_clones_container : FakeClonesContainer = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Left/FakeClonesContainer

@onready var _score_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Right/ScoreContainer/ScoreLineEdit
@onready var _zone_points_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Right/ZonePointsContainer/ZonePointsLineEdit
@onready var _damage_line_edit : LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Right/DamageContainer/DamageLineEdit
@onready var _target_texture_rect : TextureRect = $MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer/Right/TargetTextureRect

var _target : Target

func set_target(target : Target) -> void:
	_target = target
	
	_start_time_line_edit.text = Global.time_to_text(_target.get_start_time())
	_path_type_line_edit.text = Path.Types.keys()[_target.get_path_type()]
	_speed_spin_box.value = _target.get_base_speed()
	_half_reaction_check_box.button_pressed = _target.half_reaction
	
	if target is RealClone:
		_target_name.text = "<Real Clone>"
		_fake_clones_container.visible = true
	elif target is FakeClone:
		_target_name.text = "<Fake Clone>"
		_real_clone_time_line_edit.text = Global.time_to_text(_target.real_clone.get_start_time())
		_real_clone_container.visible = true
	elif target is TwoTimesDelayEditor:
		_target_name.text = "<Fortified>"
		_first_delay_time_line_edit.text = Global.time_to_text(_target.get_first_time_delay())
		_second_delay_time_line_edit.text = Global.time_to_text(_target.get_second_time_delay())
		_first_delay_time_container.visible = true
		_second_delay_time_container.visible = true
	elif target is OneTimeDelayEditor:
		_target_name.text = "<Shield>"
		_first_delay_time_line_edit.text = Global.time_to_text(_target.get_first_time_delay())
		_first_delay_time_container.visible = true
	elif target is DelayTapEditor:
		if target.get_delay_parent() is TwoTimesDelayEditor:
			_target_name.text = "<Fortified>"
		else:
			_target_name.text = "<Shield>"
		_delay_parent_time_line_edit.text = Global.time_to_text(_target.get_delay_parent().get_start_time())
		_delay_parent_time_container.visible = true
	elif target is Spam:
		_target_name.text = "<Heavy>"
		_path_type_line_edit.text = "BOTH"
		_end_time_line_edit.text = Global.time_to_text(_target.get_end_time())
		_end_time_container.visible = true
	elif target is Hold:
		_target_name.text = "<Hold>"
		_end_time_line_edit.text = Global.time_to_text(_target.get_end_time())
		_end_time_container.visible = true
	elif target is TwinTap:
		_path_type_line_edit.text = "BOTH"
		_target_name.text = "<Twins>"
	elif target is HammerTap:
		_target_name.text = "<Hammer>"
	elif target is MediumTap:
		match target.get_variant():
			MediumTap.Variants.ONE:
				_target_name.text = "<Medium 1>"
			MediumTap.Variants.TWO:
				_target_name.text = "<Medium 2>"
			_:
				_target_name.text = "<UNKNOWN>"
	elif target is LightTap:
		match target.get_variant():
			LightTap.Variants.ONE:
				_target_name.text = "<Light 1>"
			LightTap.Variants.TWO:
				_target_name.text = "<Light 2>"
			LightTap.Variants.THREE:
				_target_name.text = "<Light 3>"
			_:
				_target_name.text = "<UNKNOWN>"
	elif target is AxeTrap:
		_target_name.text = "<Axe Trap>"
	elif target is Heart:
		_target_name.text = "<Heart>"
	elif target is MusicalNote:
		_target_name.text = "<Musical Note>"
	elif target is Trap:
		_target_name.text = "<Trap>"
	else:
		_target_name.text = "<UNKNOWN>"
	
	_target_texture_rect.texture = _target.texture

func _on_close_requested() -> void:
	queue_free()
