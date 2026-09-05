extends ActionHold

class_name ActionCinematic

func create_manual_target() -> ManualTarget:
	var manual_target := ManualTargetActionHold.new(start_time, end_time, Path.Types.GROUND, self)
	manual_target.texture = SideEditorTexture.CINEMATIC_ICON_TEXTURE
	manual_target._end_hold.texture = SideEditorTexture.CINEMATIC_ICON_TEXTURE
	return manual_target
