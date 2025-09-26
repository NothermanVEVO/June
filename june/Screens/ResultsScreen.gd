extends Control

class_name ResultsScreen

enum Letters {Z = 1000000, S = 970000, A = 900000, B = 800000, C = 650000, D = 500000}

var score : int = 1000000
var combo : int
var sections : Dictionary

var _time : float = 0.0
const _MAXIMUM_TIME : float = 2.0

@onready var _progress_bar : TextureProgressBar = $LetterBase/TextureProgressBar
@onready var _score_text : RichTextLabel = $ScoreInfo/PanelContainer/MarginContainer/VBoxContainer/Score
@onready var _combo_text : RichTextLabel = $ScoreInfo/PanelContainer/MarginContainer/VBoxContainer/Combo

@onready var _in_particles : CPUParticles2D = $InParticles
@onready var _out_particles : CPUParticles2D = $OutParticles

@onready var _letter_results_animation : AnimationPlayer = $Result

var for_loading : bool = false

func _ready() -> void:
	set_physics_process(false)
	if not for_loading:
		load_ended_game_values()
		pass
	

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("Add Item"):
		#_letter_results_animation.play("Pop Letter A")

func _physics_process(delta: float) -> void:
	_time += delta
	_time = clampf(_time, 0, _MAXIMUM_TIME)
	var percentage := Global.get_percentage_between(0, _MAXIMUM_TIME, _time)
	_score_text.text = "Pontuação: " + Global.formate_int_to_pontuation(score * percentage)
	_progress_bar.value = score * percentage / 10000
	_combo_text.text = "Combo: " + Global.formate_int_to_pontuation(combo * percentage)
	
	if percentage == 1.0:
		set_physics_process(false)
		
		if score == Letters.Z:
			_player_letter_animation(Letters.Z)
		elif score < Letters.Z and score >= Letters.S:
			_player_letter_animation(Letters.S)
		elif score < Letters.S and score >= Letters.A:
			_player_letter_animation(Letters.A)
		elif score < Letters.A and score >= Letters.B:
			_player_letter_animation(Letters.B)
		elif score < Letters.B and score >= Letters.C:
			_player_letter_animation(Letters.C)
		elif score < Letters.C:
			_player_letter_animation(Letters.D)
		
		#var n : int = 0
		#var all_precision : float = 0.0
		#for section in _sections:
			#print(section)

func load_ended_game_values() -> void:
	Game.load_result_screen_values(self)
	
	await get_tree().create_timer(1).timeout
	
	set_physics_process(true)

func _player_letter_animation(letter : Letters) -> void:
	await get_tree().create_timer(1).timeout
	_in_particles.emitting = true
	await get_tree().create_timer(0.5).timeout
	match letter:
		Letters.Z:
			_letter_results_animation.play("Pop Letter Z")
		Letters.S:
			_letter_results_animation.play("Pop Letter S")
		Letters.A:
			_letter_results_animation.play("Pop Letter A")
		Letters.B:
			_letter_results_animation.play("Pop Letter B")
		Letters.C:
			_letter_results_animation.play("Pop Letter C")
		Letters.D:
			_letter_results_animation.play("Pop Letter D")

func _on_return_pressed() -> void:
	Game.change_to_selection()

func load_gear(loading_screen : LoadingScreen) -> int:
	_in_particles.emitting = true
	_letter_results_animation.play("Pop Letter Z")
	
	_letter_results_animation.animation_finished.connect(loading_screen.loaded)
	_in_particles.finished.connect(loading_screen.loaded)
	
	return 2
