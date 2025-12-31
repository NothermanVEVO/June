extends Pathway

class_name PathwayPlayer

var _character : Character

func _init(character : Character, direction : Direction) -> void:
	_character = character
	
	_ground_path = PathPlayer.new(Path.Types.GROUND, direction)
	_air_path = PathPlayer.new(Path.Types.AIR, direction)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1_air") or Input.is_action_just_pressed("2_air"):
		_ground_path.is_player_inside = false
		_air_path.is_player_inside = true
		if not _character.can_fly():
			get_tree().create_timer(Character.TIME_ON_AIR).timeout.connect(_get_down_player)
	
	if Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("2_ground"):
		_ground_path.is_player_inside = true
		_air_path.is_player_inside = false

func _get_down_player() -> void:
	_ground_path.is_player_inside = true
	_air_path.is_player_inside = false
