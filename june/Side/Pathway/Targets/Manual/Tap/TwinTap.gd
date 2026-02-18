extends Tap

class_name TwinTap

var _twin : TwinTap

var _older : bool

var _is_alive : bool

func _init(start_time : float, path_type : Path.Types, older : bool, older_twin : TwinTap = null) -> void:
	_older = older
	if _older:
		_twin = TwinTap.new(start_time, path_type, not _older)
	else:
		_twin = older_twin
	super._init(start_time, path_type)

func set_start_time(start_time : float) -> void:
	_start_time = start_time
	if _older and _twin:
		_twin.set_start_time(start_time)

func set_path_type(path_type : Path.Types) -> void:
	_path_type = path_type
	if _path_type == Path.Types.GROUND:
		texture = SideEditor.GROUND_TWIN_TEXTURE
	else:
		texture = SideEditor.AIR_TWIN_TEXTURE
	if _older and _twin:
		_twin.set_path_type(Path.reverse_path_type(path_type))

func get_twin() -> TwinTap:
	return _twin

func is_older() -> bool:
	return _older

func is_alive() -> bool:
	return _is_alive

func create_target_editor() -> void:
	super.create_target_editor()
	if _older and _twin:
		_twin.create_target_editor()

func get_global_rect() -> Rect2:
	if _older and texture:
		return Rect2(global_position.x - texture.get_width() / 2, global_position.y - texture.get_height() / 2, texture.get_width(), texture.get_height()).merge(Rect2(_twin.global_position.x - _twin.texture.get_width() / 2, _twin.global_position.y - _twin.texture.get_height() / 2, _twin.texture.get_width(), _twin.texture.get_height()))
	else:
		return Rect2(global_position.x, global_position.y, 0, 0)
