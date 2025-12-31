extends Node2D

class_name Character

const TIME_ON_AIR : float = 0.3

var _hp : float
var _can_fly : bool

func can_fly() -> bool:
	return _can_fly
