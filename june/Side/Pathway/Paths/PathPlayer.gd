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
		_process_hold()
	elif _targets[_currently_target_idx] is Spam:
		_process_spam()
	elif _targets[_currently_target_idx] is Tap:
		_process_tap()
	elif _targets[_currently_target_idx] is Trap:
		pass
	elif _targets[_currently_target_idx] is MusicalNote:
		pass

func _process_hold() -> void:
	if Song.get_time() + MAX_TIME_HIT > _targets[_currently_target_idx].get_start_time():
		return
	
	if not _targets[_currently_target_idx].has_hitted() and _targets[_currently_target_idx].is_just_pressed(): ## HITTED
		_targets[_currently_target_idx].hit()
	
	if _targets[_currently_target_idx].has_hitted() and _targets[_currently_target_idx].is_just_released(): ## RELEASED
		_targets[_currently_target_idx].released()
	
	if ((_targets[_currently_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT and not _targets[_currently_target_idx].has_hitted()) or
		_targets[_currently_target_idx].get_end_time() + MAX_TIME_HIT < Song.get_time()): ## COLLIDE
		
		_targets[_currently_target_idx].collide()

func _process_spam() -> void:
	if Song.get_time() + MAX_TIME_HIT > _targets[_currently_target_idx].get_start_time():
		return
	
	if _targets[_currently_target_idx].is_just_pressed(): ## HITTED
		_targets[_currently_target_idx].hit()
	
	if _targets[_currently_target_idx].has_hitted_all():
		_currently_target_idx += 1
	
	if ((_targets[_currently_target_idx].get_end_time() + MAX_TIME_HIT < Song.get_time() and not _targets[_currently_target_idx].has_hitted_min()) or
		(_targets[_currently_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT and _targets[_currently_target_idx].get_current_hits() == 0)):
		
		_targets[_currently_target_idx].collide()

func _process_tap() -> void:
	if Song.get_time() + MAX_TIME_HIT > _targets[_currently_target_idx].get_start_time():
		return
	
	if _targets[_currently_target_idx].is_just_pressed(): ## HITTED
		_targets[_currently_target_idx].hit()
	
	if _targets[_currently_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT: ## BREAK
		_targets[_currently_target_idx].collide()

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
