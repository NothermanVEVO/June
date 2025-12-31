extends Path

class_name PathPlayer

var _currently_target_idx : int = 0

var is_player_inside : bool = false

func _process(delta: float) -> void:
	if _currently_target_idx >= _targets.size():
		return
	
	if _targets[_currently_target_idx] is Delay:
		pass
	elif _targets[_currently_target_idx] is Hold:
		pass
	elif _targets[_currently_target_idx] is Spam:
		pass
	elif _targets[_currently_target_idx] is Tap:
		_process_tap()
	elif _targets[_currently_target_idx] is Trap:
		pass
	elif _targets[_currently_target_idx] is MusicalNote:
		pass

func _process_tap() -> void:
	pass
