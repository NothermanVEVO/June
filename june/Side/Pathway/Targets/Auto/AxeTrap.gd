extends Trap

class_name AxeTrap

const OFFSET_Y : float = 540
const DISTANCE_TO_CENTER : float = 445.0

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.AXE_TEXTURE
	offset.y = -OFFSET_Y

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func set_path_type(path_type : Path.Types) -> void:
	super.set_path_type(path_type)
	if path_type == Path.Types.AIR:
		offset.y = -OFFSET_Y
		flip_v = false
		position.y = OFFSET_Y + DISTANCE_TO_CENTER
	else:
		offset.y = OFFSET_Y
		flip_v = true
		position.y = -OFFSET_Y - DISTANCE_TO_CENTER

func get_global_rect() -> Rect2:
	var off : float = OFFSET_Y
	if _path_type == Path.Types.AIR:
		off *= -1
	return Rect2(global_position.x - texture.get_size().x / 2, global_position.y - texture.get_size().y / 2 + off, texture.get_size().x, texture.get_size().y)
