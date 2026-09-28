extends AutoTarget

class_name Trap

var _thorns : Sprite2D

var _thorns_rotation_speed : float = 2.0

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.TRAP_TEXTURE

func _ready() -> void:
	_thorns = Sprite2D.new()
	add_child(_thorns)
	_thorns.texture = SideEditorTexture.TRAP_THORNS_TEXTURE

func _process(delta: float) -> void:
	_time_rotation += delta

	rotation = _time_rotation * _thorns_rotation_speed
	_thorns.rotation = _time_rotation * _thorns_rotation_speed * -2
