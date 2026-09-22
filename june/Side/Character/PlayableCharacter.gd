extends Character

class_name PlayableCharacter

@onready var sprite : Sprite2D = $JuneSpritesheet

const _AIR_ANIMATIONS : Array[String] = ["Uppercut", "LeftPunch", "Kick"]
const _GROUND_ANIMATIONS : Array[String] = ["HittingDown", "LeftPunch", "Kick"]

@export var _animation_player : AnimationPlayer

var _current_air_time : float = 0

signal hitted_air
signal hitted_ground

func _ready() -> void:
	_animation_player.play("Running")
	_animation_player.animation_finished.connect(_animation_finished)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("1_air") or Input.is_action_just_pressed("2_air"):
		hitted_air.emit()
		if not _in_the_air:
			reset_current_air_time()
			jump()
			_animation_player.play("Uppercut")
		else:
			_animation_player.stop()
			_animation_player.play(_AIR_ANIMATIONS.pick_random())
	
	if Input.is_action_just_pressed("1_ground") or Input.is_action_just_pressed("2_ground"):
		hitted_ground.emit()
		if _in_the_air:
			reset_current_air_time()
			_animation_player.play("HittingDown")
			fall()
		else:
			_animation_player.stop()
			_animation_player.play(_GROUND_ANIMATIONS.pick_random())

func reset_current_air_time() -> void:
	_current_air_time = 0

func _animation_finished(anim_name : StringName) -> void:
	if anim_name != "Running":
		_animation_player.play("Running")
	
	if _in_the_air:
		fall()

func jump() -> void:
	_in_the_air = true
	
	if _fall_tween:
		_fall_tween.kill()
	
	_jump_tween = create_tween()

	_jump_tween.tween_property(
		sprite,
		"position:y",
		-JUMP_HEIGHT,
		JUMP_DURATION
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func fall() -> void:
	_in_the_air = false
	
	if _jump_tween:
		_jump_tween.kill()
	
	_fall_tween = create_tween()

	_fall_tween.tween_property(
		sprite,
		"position:y",
		0,
		FALL_DURATION
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
