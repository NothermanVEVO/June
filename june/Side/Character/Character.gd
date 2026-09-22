extends Node2D

class_name Character

const JUMP_HEIGHT : float = 300
const TIME_ON_AIR : float = 0.3

const JUMP_DURATION : float = 0.3
const FALL_DURATION : float = 0.3

var _jump_tween : Tween
var _fall_tween : Tween

var _hp : float
var _in_the_air : bool
var _can_fly : bool

func take_damage(damage : float) -> void:
	_hp -= damage

func get_hp() -> float:
	return _hp

func can_fly() -> bool:
	return _can_fly

func is_in_the_air() -> bool:
	return _in_the_air
