extends Control

class_name SideGame

@onready var _character_scene : PackedScene = load("res://Side/GamePlayer/JuneV1.tscn")
@onready var _character : PlayableCharacter = _character_scene.instantiate()

@onready var _precision: Precision = $MarginContainer/Precision
@onready var _combo: Combo = $Combo
@onready var _finalization: SideFinalization = $Finalization

var _pathway_player : PathwayPlayer

var total_combo : int = 0
var total_score : float = 0.0

static var _current_time : float = 0.0
const TIME_TO_START : float = 4.0

func _ready() -> void:
	_current_time = 0.0
	
	Path.hitzone = Path.BASE_HITZONE
	Path.width = Pathway.MAX_WIDTH
	
	_pathway_player = PathwayPlayer.new(_character, Pathway.Direction.RIGHT)
	_pathway_player.load_song_map(SideGlobal.get_asked_song_map())
	_pathway_player.hitted_target.connect(_hitted_target)
	_pathway_player.hitted_all_targets.connect(_hitted_all_targets)
	add_child(_pathway_player)
	
	_combo.set_combo(0)
	
	#Song.play(Song.get_time())

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Escape") and SideGlobal.was_asked_to_play_from_editor():
		get_tree().change_scene_to_packed(SideEditor.editor_composer_scene)

func _physics_process(delta: float) -> void:
	_current_time += delta
	if _current_time >= TIME_TO_START:
		Song.play(Song.get_time())
		set_physics_process(false)

func _hitted_target(precision : int, score : float) -> void:
	_precision.pop_precision(precision)
	if precision == 0:
		total_combo = 0
	else:
		total_combo += 1
	_combo.set_combo(total_combo)
	
	total_score += score

func _hitted_all_targets(_quant_max : int, quant_ok : int, quant_break : int) -> void:
	if quant_break > 0:
		_finalization.pop(SideFinalization.Type.CLEAR)
	elif quant_ok > 0:
		_finalization.pop(SideFinalization.Type.MAX_COMBO)
	else:
		_finalization.pop(SideFinalization.Type.PERFECT_COMBO)

static func get_current_time() -> float:
	return _current_time
