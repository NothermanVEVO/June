extends ActionHold

class_name ActionFade

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.FADE_ICON_TEXTURE
	return auto_target
