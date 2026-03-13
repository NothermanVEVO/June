extends HoldManual

class_name ManualTargetActionHold

var _action : Action

func _init(start_time : float, end_time : float, path_type : Path.Types, action : Action) -> void:
	super._init(start_time, end_time, path_type)
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
