extends Window

class_name TargetInfoWindow

@onready var _start_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/StartTimeContainer
@onready var _end_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/EndTimeContainer
@onready var _path_type_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/PathTypeContainer
@onready var _speed_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/SpeedContainer
@onready var _half_reaction_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/HalfReactionContainer
@onready var _delay_parent_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/DelayParentTimeContainer
@onready var _first_delay_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/FirstDelayTimeContainer
@onready var _second_delay_time_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/SecondDelayTimeContainer
@onready var _real_clone_container : HBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer/RealCloneTimeContainer
@onready var _fake_clones_container : FakeClonesContainer = $MarginContainer/ScrollContainer/VBoxContainer/FakeClonesContainer
#@onready var _start_time_container : HBoxContainer = 
#@onready var _start_time_container : HBoxContainer = 
#@onready var _start_time_container : HBoxContainer = 
#@onready var _start_time_container : HBoxContainer = 

var _target : Target

func set_target(target : Target) -> void:
	_target = target
	
	if target is RealClone:
		_fake_clones_container.visible = true
	elif target is FakeClone:
		_real_clone_container.visible = true
	elif target is TwoTimesDelayEditor:
		_first_delay_time_container.visible = true
		_second_delay_time_container.visible = true
	elif target is OneTimeDelayEditor:
		_first_delay_time_container.visible = true
	elif target is DelayTapEditor:
		_delay_parent_time_container.visible = true
	elif target is Spam:
		_end_time_container.visible = true
	elif target is Hold:
		_end_time_container.visible = true
	elif target is TwinTap:
		pass

func _on_close_requested() -> void:
	queue_free()
