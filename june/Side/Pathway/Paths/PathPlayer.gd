extends Path

class_name PathPlayer

var _currently_manual_target_idx : int = 0
var _currently_auto_target_idx : int = 0

var is_player_inside : bool = false

func _process(delta: float) -> void:
	if _currently_manual_target_idx < _manual_targets.size(): ## MANUAL
		if _manual_targets[_currently_manual_target_idx] is Delay:
			_process_delay()
		elif _manual_targets[_currently_manual_target_idx] is Hold:
			_process_hold()
		elif _manual_targets[_currently_manual_target_idx] is Spam:
			_process_spam()
		elif _manual_targets[_currently_manual_target_idx] is Tap:
			_process_tap()

	if _currently_auto_target_idx < _auto_targets.size(): ## AUTO
		if (_auto_targets[_currently_auto_target_idx] is Trap
		or _auto_targets[_currently_auto_target_idx] is MusicalNote
		or _auto_targets[_currently_auto_target_idx] is Heart):
			_process_auto()

func _process_delay() -> void:
	pass

func _process_hold() -> void:
	if Song.get_time() + MAX_TIME_HIT > _manual_targets[_currently_manual_target_idx].get_start_time():
		return
	
	if not _manual_targets[_currently_manual_target_idx].has_hitted() and _manual_targets[_currently_manual_target_idx].is_just_pressed(): ## HITTED
		_manual_targets[_currently_manual_target_idx].hit()
		_change_to_next_manual_target()
	
	if _manual_targets[_currently_manual_target_idx].has_hitted() and _manual_targets[_currently_manual_target_idx].is_just_released(): ## RELEASED
		_manual_targets[_currently_manual_target_idx].released()
		if _manual_targets[_currently_manual_target_idx].get_end_time() - MAX_TIME_HIT < Song.get_time():
			_manual_targets[_currently_manual_target_idx].collide()
		_change_to_next_manual_target()
	
	if _manual_targets[_currently_manual_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT and not _manual_targets[_currently_manual_target_idx].has_hitted():
		if is_player_inside and _manual_targets[_currently_manual_target_idx].is_colliding(Song.get_time()):
			_manual_targets[_currently_manual_target_idx].collide()
		else:
			pass ## BREAK TODO
		_change_to_next_manual_target()
	
	if _manual_targets[_currently_manual_target_idx].get_end_time() + MAX_TIME_HIT < Song.get_time():
		_manual_targets[_currently_manual_target_idx].collide()
		_change_to_next_manual_target()

func _process_spam() -> void:
	if Song.get_time() + MAX_TIME_HIT > _manual_targets[_currently_manual_target_idx].get_start_time():
		return
	
	if _manual_targets[_currently_manual_target_idx].is_just_pressed(): ## HITTED
		_manual_targets[_currently_manual_target_idx].hit()
	
	if _manual_targets[_currently_manual_target_idx].has_hitted_all():
		_change_to_next_manual_target()
	
	if ((_manual_targets[_currently_manual_target_idx].get_end_time() + MAX_TIME_HIT < Song.get_time() and not _manual_targets[_currently_manual_target_idx].has_hitted_min()) or
		(_manual_targets[_currently_manual_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT and _manual_targets[_currently_manual_target_idx].get_current_hits() == 0)):
		
		_manual_targets[_currently_manual_target_idx].collide()
		_change_to_next_manual_target()

func _process_tap() -> void:
	if Song.get_time() + MAX_TIME_HIT > _manual_targets[_currently_manual_target_idx].get_start_time():
		return
	
	if _manual_targets[_currently_manual_target_idx].is_just_pressed(): ## HITTED
		_manual_targets[_currently_manual_target_idx].hit()
		_change_to_next_manual_target()
	
	if _manual_targets[_currently_manual_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT:
		if is_player_inside and _manual_targets[_currently_manual_target_idx].is_colliding(Song.get_time()):
			_manual_targets[_currently_manual_target_idx].collide()
			_change_to_next_manual_target()
		else:
			pass ## BREAK TODO

func _process_auto() -> void:
	if Song.get_time() + MAX_TIME_HIT > _auto_targets[_currently_auto_target_idx].get_start_time():
		return
	
	if _auto_targets[_currently_auto_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT:
		if is_player_inside and _auto_targets[_currently_auto_target_idx].is_colliding(Song.get_time()):
			_auto_targets[_currently_auto_target_idx].collide()
			_currently_auto_target_idx += 1

func _process_note() -> void:
	pass

func _change_to_next_manual_target() -> void:
	_currently_manual_target_idx += 1
	if _manual_targets[_currently_manual_target_idx] is Blank:
		_change_to_next_manual_target()

func _calculate_difference(time : float, target_time : float) -> int:
	var difference : float = Global.get_percentage_between(time, time + MAX_TIME_HIT, target_time) * 100
	var value : int = sign(difference)
	difference = abs(abs(difference) - 100)
	return _calculate_round_precision(difference, value)

func _calculate_round_precision(difference : float, value : int) -> int: ## YES... EVERYTHING IS A LIE.
	if difference >= 80.0: ## TO NOT BE SO FRUSTRATING
		return 100
	elif difference >= 72.5 and difference < 80.0:
		return 90 * value
	elif difference >= 65.0 and difference < 72.5:
		return 80 * value
	elif difference >= 57.5 and difference < 65.0:
		return 70 * value
	elif difference >= 52.5 and difference < 57.5:
		return 60 * value
	elif difference >= 47.5 and difference < 52.5:
		return 50 * value
	elif difference >= 42.5 and difference < 47.5:
		return 40 * value
	elif difference >= 37.5 and difference < 42.5:
		return 30 * value
	elif difference >= 32.5 and difference < 37.5:
		return 20 * value
	elif difference >= 25.0 and difference < 32.5:
		return 10 * value
	elif difference >= 20.0 and difference < 25.0:
		return 1 * value
	elif difference >= 0.0 and difference < 20.0: ## YOU BETTER NOT TRY TO SPAM
		return 0
	return 0
