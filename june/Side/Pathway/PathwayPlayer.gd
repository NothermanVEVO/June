extends Pathway

class_name PathwayPlayer

var _character : Character

static var _time_after_song_finished : float = 0.0

var quant_paths_completed : int = 0

var _quant_max : int
var _quant_ok : int
var _quant_break : int

signal hitted_all_targets(quant_max : int, quant_ok : int, quant_break : int)

signal hitted_target(precision : float, score : float)

func _init(character : Character, direction : Direction) -> void:
	_character = character
	
	_time_after_song_finished = 0.0
	
	_ground_path = PathPlayer.new(Path.Types.GROUND, direction)
	_air_path = PathPlayer.new(Path.Types.AIR, direction)
	
	_ground_path.hitted_target.connect(_hitted_target)
	_air_path.hitted_target.connect(_hitted_target)
	
	_ground_path.hitted_all_targets.connect(_hitted_all_targets)
	_air_path.hitted_all_targets.connect(_hitted_all_targets)

func _ready() -> void:
	add_child(_ground_path)
	add_child(_air_path)
	
	_ground_path.character = _character
	_air_path.character = _character
	
	position.y = MAX_HEIGHT - DISTANCE_FROM_BOTTOM
	
	_air_path.position.y -= Path.HEIGHT
	_ground_path.position.y += Path.HEIGHT
	
	_ground_path.is_player_inside = true

func load_song_map(song_map : SideSongMap) -> void:
	for target_res in song_map.targets:
		var target := TargetResource.resource_to_target(target_res)
		if target:
			add_target_at(target.get_path_type(), target)

func _process(delta: float) -> void:
	if Song.is_finished():
		_time_after_song_finished += delta
	
	if Input.is_action_just_pressed("1_air") or Input.is_action_just_pressed("2_air"):
		_ground_path.is_player_inside = false
		_air_path.is_player_inside = true
	
	if Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("2_ground"):
		_ground_path.is_player_inside = true
		_air_path.is_player_inside = false

func _get_down_player() -> void:
	_ground_path.is_player_inside = true
	_air_path.is_player_inside = false

func _hitted_target(precision : int, score : float) -> void:
	hitted_target.emit(precision, score)

func _hitted_all_targets(quant_max : int, quant_ok : int, quant_break : int) -> void:
	quant_paths_completed += 1
	_quant_max += quant_max
	_quant_ok += quant_ok
	_quant_break += quant_break
	
	if quant_paths_completed == 2: ## AIR PATH AND GROUND PATH ONLY
		hitted_all_targets.emit(_quant_max, _quant_ok, _quant_break)

static func get_time_after_song_finished() -> float:
	return _time_after_song_finished
