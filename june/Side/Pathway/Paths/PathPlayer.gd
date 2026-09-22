extends Path

class_name PathPlayer

var _time : float

var character : Character

var _currently_manual_target_idx : int = 0
var _currently_auto_target_idx : int = 0

var is_player_inside : bool = false

var _quant_max : int
var _quant_ok : int
var _quant_break : int

var _start_hit_precision : int
var _current_time_to_next_hit_hold : float = 0.0
const TIME_TO_NEXT_HIT_HOLD : float = 0.3

var _spam_time_since_last_hit : float = 0.0
const MAX_SPAM_TIME_LAST_HIT : float = 0.75

signal hitted_all_targets(quant_max : int, quant_ok : int, quant_break : int)
signal hitted_target(precision : int, score : float)

func _ready() -> void:
	if _currently_manual_target_idx >= _manual_targets.size() and _currently_auto_target_idx >= _auto_targets.size():
		hitted_all_targets.emit(_quant_max, _quant_max, _quant_break)
	
	queue_redraw() ## TEMP

func _draw() -> void: ## TEMP
	draw_rect(Rect2(0, - HEIGHT / 2, width, HEIGHT), Color.WHITE, false, 1, true)
	
	draw_line(Vector2(hitzone, -HEIGHT / 2), Vector2(hitzone, HEIGHT / 2), Color.YELLOW, 10)

func _process(delta: float) -> void:
	if SideGame.get_current_time() >= SideGame.TIME_TO_START and not Song.is_finished():
		_time = Song.get_time()
	elif SideGame.get_current_time() < SideGame.TIME_TO_START:
		_time = Song.get_time() + SideGame.get_current_time() - SideGame.TIME_TO_START
	elif Song.is_finished() and Song.get_time() >= Song.get_duration():
		_time = Song.get_duration() + PathwayPlayer.get_time_after_song_finished()
	
	_display_targets(_time)
	
	if _currently_manual_target_idx < _manual_targets.size(): ## MANUAL
		var manual_target : Target = _manual_targets[_currently_manual_target_idx]
		
		if manual_target is Blank or manual_target is HoldBlank:
			_change_to_next_manual_target()
		#if manual_target is Delay:
			#_process_delay()
		elif manual_target is Spam:
			_process_spam(delta)
		elif manual_target is HoldManual:
			_process_hold(delta)
		elif manual_target is Tap:
			_process_tap()
#
	#if _currently_auto_target_idx < _auto_targets.size(): ## AUTO
		#if (_auto_targets[_currently_auto_target_idx] is Trap
		#or _auto_targets[_currently_auto_target_idx] is MusicalNote
		#or _auto_targets[_currently_auto_target_idx] is Heart):
			#_process_auto()
	

func _process_delay() -> void:
	if Song.get_time() + MAX_TIME_HIT > _manual_targets[_currently_manual_target_idx].get_current_time():
		return
	
	if _manual_targets[_currently_manual_target_idx].is_just_pressed() and not _manual_targets[_currently_manual_target_idx].has_hitted_all():
		_manual_targets[_currently_manual_target_idx].hit()
		if _manual_targets[_currently_manual_target_idx].has_hitted_all():
			_change_to_next_manual_target()
	
	if _manual_targets[_currently_manual_target_idx].is_colliding(Song.get_time()):
		_manual_targets[_currently_manual_target_idx].collide(character)
		_change_to_next_manual_target()

func _process_hold(delta : float) -> void:
	var target : HoldManual = _manual_targets[_currently_manual_target_idx]
	
	if not target.has_hitted() and target.is_just_pressed() and _time_in_song_range(target.get_start_time()): ## HITTED
		target.hit()
		
		var precision : int = _calculate_difference(_time, target.get_start_time())
		_start_hit_precision = precision
		_hit_precision(precision, target)
	elif target.get_end_time() + (MAX_TIME_HIT * 2) < _time:
		hitted_target.emit(0, 0)
		_quant_break += 1
		modulate.a = 0.5
		_change_to_next_manual_target()
	elif target.has_hitted() and target.is_pressed():
		_current_time_to_next_hit_hold += delta
		if _current_time_to_next_hit_hold >= TIME_TO_NEXT_HIT_HOLD:
			_current_time_to_next_hit_hold -= TIME_TO_NEXT_HIT_HOLD
			_hit_precision(_start_hit_precision, target)
	elif target.has_hitted() and target.is_just_released(): ## RELEASED
		target.release()
		if target.get_end_time() > _time + MAX_TIME_HIT:
			hitted_target.emit(0, 0)
			_quant_break += 1
			modulate.a = 0.5
		else:
			var precision : int = _calculate_difference(_time, target.get_end_time())
			precision = precision if precision < _start_hit_precision else _start_hit_precision
			_hit_precision(precision, target)
			
		_change_to_next_manual_target()
	elif target.get_start_time() < _time - MAX_TIME_HIT and not target.has_hitted():
		if is_player_inside and target.is_colliding(_time):
			target.collide(character)
			hitted_target.emit(0, 0)
			_quant_break += 1
			modulate.a = 0.5
		else:
			hitted_target.emit(0, 0)
			_quant_break += 1
			modulate.a = 0.5
		_change_to_next_manual_target()

func _process_spam(delta : float) -> void:
	var target : Spam = _manual_targets[_currently_manual_target_idx]
	
	if (target.is_just_pressed() and target.get_start_time() - MAX_TIME_HIT <= _time and 
		_time <= target.get_end_time()): ## HITTED
		
		target.hit()
		_hit_precision(100, target)
		_spam_time_since_last_hit = 0
	
	if target.get_current_hits() > 0:
		_spam_time_since_last_hit += delta
		if _spam_time_since_last_hit >= MAX_SPAM_TIME_LAST_HIT:
			target.collide(character)
			hitted_target.emit(0, 0)
			_quant_break += 1
			_change_to_next_manual_target()
			return
	
	if _time >= target.get_end_time() + MAX_TIME_HIT and target.get_current_hits() > 0:
		target._death() ## NOT GOOD
		_change_to_next_manual_target()
		return
	#if target.has_hitted_all():
		#_change_to_next_manual_target()
	
	if target.get_current_hits() == 0 and target.get_start_time() + MAX_TIME_HIT <= _time:
		target.collide(character)
		hitted_target.emit(0, 0)
		_quant_break += 1
		_change_to_next_manual_target()

func _process_tap() -> void:
	var target : Tap = _manual_targets[_currently_manual_target_idx]
	
	if target.is_just_pressed() and target.get_start_time() >= _time - MAX_TIME_HIT and (
		target.get_start_time() <= _time + MAX_TIME_HIT): ## HITTED
		
		target.hit()
		
		var precision : int = _calculate_difference(_time, target.get_start_time())
		
		_hit_precision(precision, target)
		
		_change_to_next_manual_target()
	elif target.get_start_time() < _time - MAX_TIME_HIT:
		if is_player_inside and target.is_colliding(_time):
			target.collide(character)
			hitted_target.emit(0, 0)
			_quant_break += 1
		else:
			hitted_target.emit(0, 0)
			_quant_break += 1
		
		_change_to_next_manual_target()

func _hit_precision(precision : int, target : Target) -> void:
	var score : float = target.get_score() * (abs(precision) / 100)
	
	hitted_target.emit(precision, score)
		
	if precision > 50:
		_quant_max += 1
	else:
		_quant_ok += 1

func _time_in_song_range(time : float) -> bool:
	return time >= _time - MAX_TIME_HIT and time <= _time + MAX_TIME_HIT

func _process_auto() -> void:
	if Song.get_time() + MAX_TIME_HIT > _auto_targets[_currently_auto_target_idx].get_start_time():
		return
	
	if _auto_targets[_currently_auto_target_idx].get_start_time() < Song.get_time() - MAX_TIME_HIT:
		if is_player_inside and _auto_targets[_currently_auto_target_idx].is_colliding(Song.get_time()):
			_auto_targets[_currently_auto_target_idx].collide(character)
			_currently_auto_target_idx += 1

func _process_note() -> void:
	pass

func _change_to_next_manual_target() -> void:
	_currently_manual_target_idx += 1
	
	_current_time_to_next_hit_hold = 0
	_spam_time_since_last_hit = 0
	
	if _currently_manual_target_idx < _manual_targets.size() and _manual_targets[_currently_manual_target_idx] is Blank:
		_change_to_next_manual_target()
	
	if _currently_auto_target_idx >= _auto_targets.size() and _currently_manual_target_idx >= _manual_targets.size():
		hitted_all_targets.emit(_quant_max, _quant_ok, _quant_break)

func _calculate_difference(time : float, target_time : float) -> int:
	var difference : float = Global.get_percentage_between(time, time + MAX_TIME_HIT, target_time) * 100
	difference = abs(abs(difference) - 100)
	return _calculate_round_precision(difference)

func _calculate_round_precision(difference : float) -> int: ## YES... EVERYTHING IS A LIE.
	if difference >= 50.0: ## TO NOT BE SO FRUSTRATING
		return 100
	else:
		return 50

func _display_targets(time : float) -> void:
	var targets := get_targets(time - (WIDTH_IN_SECS_BY_SPEED() / 3), time + WIDTH_IN_SECS_BY_SPEED() + (WIDTH_IN_SECS_BY_SPEED() / 3))
	
	for target in _last_visible_targets:
		if not target in targets:
			target.visible = false
	_last_visible_targets.clear()
	
	for target in targets:
		if target is Blank or target is HoldBlank:
			continue
		
		target.visible = true
		_last_visible_targets.append(target)
		
		if not target.is_in_knockback_state():
			if target is Spam and target.get_current_hits() > 0 and not target.is_dead():
				target.position.x = hitzone
				continue
			elif target is HoldManual and not target is Spam and target.has_hitted():
				var fake_time = target.get_end_time() - (Song.get_time() - target.get_start_time())
				target.fake_end_time(fake_time)
				if target.get_end_time() > Song.get_time():
					target.position.x = hitzone
					continue
				else:
					target.position.x = get_pos_x(time, time + WIDTH_IN_SECS_BY_SPEED(), target.get_start_time(), hitzone, width)
			else:
				target.position.x = get_pos_x(time, time + WIDTH_IN_SECS_BY_SPEED(), target.get_start_time(), hitzone, width)
		elif target is Spam:
			continue
		
		if target.get_start_time() < time:
			var p_time = time
			var difference = get_pos_x(target.get_start_time(), target.get_start_time() + WIDTH_IN_SECS_BY_SPEED(), p_time, hitzone, width) - hitzone
			while p_time - WIDTH_IN_SECS_BY_SPEED() > 0.0:
				p_time -= WIDTH_IN_SECS_BY_SPEED()
				difference += get_pos_x(target.get_start_time(), target.get_start_time() + WIDTH_IN_SECS_BY_SPEED(), p_time, hitzone, width) - hitzone
			if not target.is_in_knockback_state():
				target.position.x -= difference
		elif target.get_start_time() > time + WIDTH_IN_SECS_BY_SPEED():
			var p_time = target.get_start_time() - (time + WIDTH_IN_SECS_BY_SPEED())
			var difference = get_pos_x(0, WIDTH_IN_SECS_BY_SPEED(), p_time, 0, width)
			while p_time > WIDTH_IN_SECS_BY_SPEED():
				p_time -= WIDTH_IN_SECS_BY_SPEED()
				difference -= get_pos_x(0, WIDTH_IN_SECS_BY_SPEED(), p_time, 0, width)
			if not target.is_in_knockback_state():
				target.position.x += difference

func add_manual_target(manual_target : ManualTarget) -> void:
	super.add_manual_target(manual_target)
	if manual_target is Spam:
		manual_target.hide_editor_visual.call_deferred()
