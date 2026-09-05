extends ActionFramed

class_name ActionDialog

func create_manual_target() -> ManualTarget:
	var manual_target := ManualTargetActionHold.new(start_time, end_time, Path.Types.GROUND, self)
	manual_target.texture = SideEditorTexture.DIALOG_ICON_TEXTURE
	manual_target._end_hold.texture = SideEditorTexture.DIALOG_ICON_TEXTURE
	return manual_target
