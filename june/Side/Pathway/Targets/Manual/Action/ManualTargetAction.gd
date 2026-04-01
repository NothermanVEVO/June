extends ManualTarget

class_name ManualTargetAction

var _action : Action

var path_index : int

func _init(start_time : float, path_type : Path.Types, action : Action) -> void:
	super._init(start_time, path_type)
	
	scale *= 1.5 ## TEMP??
	texture_changed.connect(_texture_changed) ## TEMP??
	
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

func _texture_changed() -> void:
	## DO THIS BECAUSE OF THE SCALE, IMPROVE THIS SHIT LATER
	position.y += (get_rect().size.y * 1.25) + 2 ## WHY 2?? I DON'T KNOW, AND I'M NOT GONNA STRESS WITH IT FOR NOW

func get_global_rect() -> Rect2:
	if texture:
		return Rect2(global_position.x - texture.get_width() / 2, global_position.y - texture.get_height() / 2, texture.get_width(), texture.get_height())
	else:
		return Rect2(global_position.x, global_position.y, 0, 0)
