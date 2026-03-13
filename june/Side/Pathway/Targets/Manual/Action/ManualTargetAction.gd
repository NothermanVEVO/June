extends ManualTarget

class_name ManualTargetAction

var _action : Action

func _init(start_time : float, path_type : Path.Types, action : Action) -> void:
	super._init(start_time, path_type)
	_action = action
	create_target_editor()
	
	if action is ActionChangeEnemy:
		pass
	elif action is ActionChangeScenerio:
		pass
	elif action is ActionComment:
		pass
	elif action is ActionSection:
		pass
	elif action is ActionSpeed:
		pass
	elif action is ActionShake:
		pass
