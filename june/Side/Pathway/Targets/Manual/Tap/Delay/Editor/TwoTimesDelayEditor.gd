extends OneTimeDelayEditor

class_name TwoTimesDelayEditor

var _second_delay_tap : DelayTapEditor

func _init(start_time : float, first_time_delay : float, second_time_delay : float, path_type : Path.Types) -> void:
	_second_delay_tap = DelayTapEditor.new(second_time_delay, path_type, self)
	super._init(start_time, first_time_delay, path_type)
	texture = SideEditor.SHIELD_2_TEXTURE
	_first_delay_tap.texture = SideEditor.SHIELD_1_TEXTURE
	_second_delay_tap.texture = SideEditor.SHIELD_0_TEXTURE

func get_second_delay_tap() -> DelayTapEditor:
	return _second_delay_tap

func get_second_time_delay() -> float:
	return _second_delay_tap.get_start_time()

func set_second_time_delay(second_time_delay : float) -> void:
	_second_delay_tap.set_start_time(second_time_delay)

func create_target_editor() -> void:
	super.create_target_editor()
	_second_delay_tap.create_target_editor()
