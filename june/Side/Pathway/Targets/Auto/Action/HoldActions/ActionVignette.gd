extends ActionHold

class_name ActionVignette

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.VIGNETTE_ICON_TEXTURE
	return auto_target
