extends OneTimeDelay

class_name OneTimeDelayEditor

var _first_delay_tap : DelayTapEditor

func _init(start_time : float, first_time_delay : float, path_type : Path.Types) -> void:
	_first_delay_tap = DelayTapEditor.new(first_time_delay, path_type, self)
	texture = SideEditor.SHIELD_1_TEXTURE
	_first_delay_tap.texture = SideEditor.SHIELD_0_TEXTURE
	super._init(start_time, first_time_delay, path_type)

func get_first_delay_tap() -> DelayTapEditor:
	return _first_delay_tap

func get_first_time_delay() -> float:
	return _first_delay_tap.get_start_time()

func set_first_time_delay(first_time_delay : float) -> void:
	_first_delay_tap.set_start_time(first_time_delay)

func create_target_editor() -> void:
	super.create_target_editor()
	_first_delay_tap.create_target_editor()
