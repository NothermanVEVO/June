extends Action

class_name ActionComment

func create_manual_target() -> ManualTarget:
	var manual_target := ManualTargetAction.new(start_time, Path.Types.GROUND, self)
	manual_target.texture = SideEditor.COMMENT_ICON_TEXTURE
	return manual_target
