extends HoldManual

class_name ManualTargetActionHold

var _action : Action

var path_index : int

func _init(start_time : float, end_time : float, path_type : Path.Types, action : Action) -> void:
	super._init(start_time, end_time, path_type)
	
	texture_changed.connect(_texture_changed)
	scale *= 1.5
	
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

func _texture_changed() -> void:
	## DO THIS BECAUSE OF THE SCALE, IMPROVE THIS SHIT LATER
	position.y += (get_rect().size.y * 1.25) + 2 ## WHY 2?? I DON'T KNOW, AND I'M NOT GONNA STRESS WITH IT FOR NOW
	_update_edit_buttons_size()

func set_start_time(start_time : float) -> void:
	super.set_start_time(start_time)
	if _action:
		_action.start_time = start_time

func set_end_time(end_time : float) -> void:
	super.set_end_time(end_time)
	
	_middle_hold.size = Vector2(_end_hold.position.x, get_rect().size.y * 0.6)
	_middle_hold.position = Vector2(0, -_middle_hold.size.y / 2)
	
	if _action and _action is ActionHold:
		_action.end_time = end_time
