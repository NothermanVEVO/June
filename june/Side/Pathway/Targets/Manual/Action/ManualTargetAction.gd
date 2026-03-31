extends ManualTarget

class_name ManualTargetAction

var _action : Action

var path_index : int

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

func get_global_rect() -> Rect2:
	if texture:
		return Rect2(global_position.x - texture.get_width() / 2, global_position.y - texture.get_height() / 2, texture.get_width(), texture.get_height())
	else:
		return Rect2(global_position.x, global_position.y, 0, 0)
