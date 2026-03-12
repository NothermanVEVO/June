extends Action

class_name ActionShake

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.SHAKE_ICON_TEXTURE
	return auto_target
