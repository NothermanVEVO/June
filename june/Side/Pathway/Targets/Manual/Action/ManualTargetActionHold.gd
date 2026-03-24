extends HoldManual

class_name ManualTargetActionHold

var _action : Action

func _init(start_time : float, end_time : float, path_type : Path.Types, action : Action) -> void:
	super._init(start_time, end_time, path_type)
	
	z_index = 1 ## TEMP, TALVEZ
	
	_action = action
	create_target_editor()
	
	if action is ActionBoss:
		pass
	elif action is ActionCamera:
		pass
	elif action is ActionCinematic:
		pass
	elif action is ActionDialog:
		pass
	elif action is ActionFade:
		pass
	elif action is ActionVignette:
		pass

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	if _action:
		_action.start_time = start_time

func set_end_time(end_time : float) -> void:
	_end_time = end_time
	
	var end_pos = Path.get_pos_x(0, get_width_in_secs_by_speed(), end_time - _start_time, Path.hitzone, Path.width) - Path.hitzone
	
	while end_time - _start_time > get_width_in_secs_by_speed():
		end_time -= get_width_in_secs_by_speed()
		end_pos += Path.get_pos_x(0, get_width_in_secs_by_speed(), end_time - _start_time, Path.hitzone, Path.width) - Path.hitzone
	
	_end_hold.position = Vector2(end_pos, 0)
	
	_update_edit_buttons_positions()
	
	if _action and _action is ActionHold:
		_action.end_time = end_time
