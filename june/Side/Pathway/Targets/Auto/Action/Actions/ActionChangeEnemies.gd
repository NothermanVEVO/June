extends Action

class_name ActionChangeEnemy

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.CHANGE_ENEMIES_ICON_TEXTURE
	return auto_target
