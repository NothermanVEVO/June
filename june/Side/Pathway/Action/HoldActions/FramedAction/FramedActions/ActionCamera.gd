extends ActionFramed

class_name ActionCamera

func create_manual_target() -> ManualTarget:
	var manual_target := ManualTargetActionHold.new(start_time, end_time, Path.Types.GROUND, self)
	manual_target.texture = SideEditor.CAMERA_ICON_TEXTURE
	return manual_target
