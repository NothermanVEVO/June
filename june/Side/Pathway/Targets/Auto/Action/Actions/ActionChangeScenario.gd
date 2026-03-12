extends Action

class_name ActionChangeScenerio

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.CHANGE_SCENARIO_ICON_TEXTURE
	return auto_target
