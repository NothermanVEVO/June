extends Action

class_name ActionComment

func create_auto_target() -> AutoTarget:
	var auto_target := AutoTarget.new(start_time, Path.Types.GROUND)
	auto_target.texture = SideEditor.COMMENT_ICON_TEXTURE
	return auto_target
