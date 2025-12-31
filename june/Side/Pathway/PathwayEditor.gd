extends Pathway

class_name PathwayEditor

func _init() -> void:
	_ground_path = PathEditor.new(Path.Types.GROUND, Direction.RIGHT)
	_air_path = PathEditor.new(Path.Types.AIR, Direction.RIGHT)

func _ready() -> void:
	add_child(_ground_path)
	add_child(_air_path)
	
	position.y = 1080 / 2
	
	_ground_path.position.y -= Path.HEIGHT
	_air_path.position.y += Path.HEIGHT

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, Color.ORANGE)
