extends FlowContainer

class_name SoundBoard

@onready var song : AudioStreamPlayer = $"../AudioStreamPlayer"

## SPEED TEXT AND SLIDER			-- START --
@onready var speed_text : TextEdit = $SpeedContainer/SpeedText
@onready var speed_slider : HSlider = $SpeedContainer/SpeedSlider

# SPEED TEXT VARS
var valid_speed_text_with_perc := RegEx.new() # VALID WITH THE PERCENTAGE SYMBOL
var valid_speed_text := RegEx.new() # VALID WITHOUT THE PERCENTAGE SYMBOL
var get_int_number := RegEx.new()
var last_valid_speed_text : String = ""
var last_pseudo_valid_speed_text : String = ""

# SPEED SLIDER VARS
var is_dragging_speed_slider : bool = false
var last_speed_value : float = 0.0
## SPEED TEXT AND SLIDER			-- END --

## TIME TEXT AND SLIDER				-- START --
@onready var time_text : TextEdit = $"Time Percentage"
@onready var time_slider : HSlider = $"Time Slider"

@onready var time_pos_text : TextEdit = $Time

# TIME TEXT VARS
var valid_time := RegEx.new()
var valid_time_with_perc := RegEx.new()
var get_float_number := RegEx.new()
var last_valid_time_text : String = ""
var last_pseudo_valid_time_text : String = ""

# TIME SLIDER VARS
var is_dragging_time_slider : bool = false
var last_time_value : float = 0.0
## TIME TEXT AND SLIDER				-- END --

# TIME POS VARS
var valid_time_pos := RegEx.new()
var last_valid_time_pos_text : String = ""
var song_was_playing : bool = false

# SONG VARS
var _temp_song_time_pos : float = 0.0
var _song_finished : bool = false

func _ready() -> void:
	## SPEED TEXT AND SLIDER
	valid_speed_text_with_perc.compile("^[0-9]+%$")
	valid_speed_text.compile("^[0-9]+$")
	get_int_number.compile("[0-9]+")
	last_valid_speed_text = speed_text.text
	last_pseudo_valid_speed_text = speed_text.text
	last_speed_value = speed_slider.value
	
	## TIME TEXT AND SLIDER
	valid_time.compile("^([0-9]*[.])?[0-9]+$")
	valid_time_with_perc.compile("^([0-9]*[.])?[0-9]+%$")
	get_float_number.compile("([0-9]*[.])?[0-9]+")
	last_valid_time_text = time_text.text
	last_pseudo_valid_time_text = time_text.text
	last_time_value = time_slider.value
	
	## TIME POS
	valid_time_pos.compile("^\\d{2}:\\d{2}:\\d{3,}$")
	
	song.finished.connect(_song_has_finished)

func _process(delta: float) -> void:
	
	## SPEED TEXT AND SLIDER
	if is_dragging_speed_slider:
		speed_text.text = str(roundi(speed_slider.value)) + "%"
	if last_speed_value != speed_slider.value:
		speed_text.text = str(roundi(speed_slider.value)) + "%"
		last_speed_value = speed_slider.value
		last_pseudo_valid_speed_text = speed_text.text
	
	## TIME TEXT AND SLIDER
	if is_dragging_time_slider:
		time_text.text = (str(time_slider.value) + "%")
		_temp_song_time_pos = song.stream.get_length() * time_slider.value / 100
		_adjust_time_pos_text(true)
	if last_time_value != time_slider.value:
		time_text.text = str(time_slider.value) + "%"
		#_temp_song_time_pos = song.stream.get_length() * time_slider.value / 100
		#song.seek(_temp_song_time_pos)
		last_time_value = time_slider.value
		last_pseudo_valid_time_text = time_text.text
		
	## SONG
	if song.playing: # THE SONG IS PLAYING
		time_slider.value = song.get_playback_position() * 100 / song.stream.get_length()
		_adjust_time_pos_text()
	elif _song_finished: # THE SONG FINISHED
		time_slider.value = 100.0
		##NOTE GAMBIARRA A SEGUIR, TO ALTERANDO O TEMP SONG TIME POS PRA AJUSTAR O TEXTO PRO TEMPO FINAL:
		_temp_song_time_pos = song.stream.get_length()
		_adjust_time_pos_text(true)
		_temp_song_time_pos = 0.0
	else: # THE SONG IS PAUSED
		time_slider.value = _temp_song_time_pos * 100 / song.stream.get_length()
	song.pitch_scale = speed_slider.value / 100 # TODO MUITO BOM KKKKKKKKK

# CHECK IF THE TEXT IN THE SPEED TEXT IS VALID
func is_speed_text_valid() -> bool:
	var is_valid_1 = valid_speed_text_with_perc.search(speed_text.text)
	var is_valid_2 = valid_speed_text.search(speed_text.text)
	return is_valid_1 or is_valid_2

## ADJUST THE SPEED IN THE SPEED TEXT AND THE SPEED SLIDER
func adjust_speed() -> void:
	if is_speed_text_valid():
		var value = str_to_var(get_int_number.search(speed_text.text).strings[0])
		if value < speed_slider.min_value:
			speed_slider.value = speed_slider.min_value
		elif value > speed_slider.max_value:
			speed_slider.value = speed_slider.max_value
		else:
			speed_slider.value = value
		speed_text.text = str(roundi(speed_slider.value)) + "%" # CORRECTS THE VALUE, IN CASE ENTERS IN THE FIRST TWO CONDITIONS
		last_valid_speed_text = speed_text.text
	else:
		speed_text.text = last_valid_speed_text
	speed_text.release_focus()

## CHANGE SPEED TIMER OR SLIDER 			-- START --
func _on_speed_text_text_changed() -> void:
	if "\n" in speed_text.text: #MEANS THAT THE ENTER WAS PRESSED
		speed_text.text = speed_text.text.replace("\n", "")
		speed_text.release_focus()
	
	if "-" in speed_text.text: # PREVENT FROM PUTTING NEGATIVE VALUES AND CONFUSING THE USER...
		speed_text.text = speed_text.text.replace("-", "") # ...CONFUSING BECAUSE IF IT ENTERS IN THE BELOW
		speed_text.release_focus()			# CONDITION, IT'LL JUST BE REMOVED AND KEEP CHANGING THE TEXT
		
	if not ("" == speed_text.text or "%" == speed_text.text): # THE SPEED TEXT IS EMPTY OR CONTAINS ONLY A '%'
	
		if not is_speed_text_valid(): # CHECK IF THE TEXT INSIDE THE SPEED TEXT IS NOT VALID
			var idx = speed_text.get_caret_column() # IF IT'S NOT, THEN ADJUST TO THE LAST CORRECT VALUE
			var difference = abs(speed_text.text.length() - last_pseudo_valid_speed_text.length())
			speed_text.text = last_pseudo_valid_speed_text
			speed_text.set_caret_column(idx - difference)
	
		else: # IF THE TEXT IN THE SPEED TEXT IS VALID, ADJUST THE SPEED SLIDER
			var value = str_to_var(get_int_number.search(speed_text.text).strings[0])
			if value < speed_slider.min_value:
				speed_slider.value = speed_slider.min_value
			elif value > speed_slider.max_value:
				speed_slider.value = speed_slider.max_value
			else:
				speed_slider.value = value
		last_speed_value = speed_slider.value
		last_pseudo_valid_speed_text = speed_text.text
		return
	last_pseudo_valid_speed_text = speed_text.text

func _on_speed_text_focus_exited() -> void: # ADJUST THE SPEED IN CASE LOSE FOCUS AND
	adjust_speed()							# THE ENTER KEY WAS NOT PRESSED

func _on_speed_slider_drag_started() -> void:
	is_dragging_speed_slider = true
	speed_text.text = str(roundi(speed_slider.value)) + "%"
	#set_process(true)

func _on_speed_slider_drag_ended(value_changed: bool) -> void:
	is_dragging_speed_slider = false
	speed_text.text = str(roundi(speed_slider.value)) + "%"
	last_pseudo_valid_speed_text = speed_text.text
	#set_process(false)

## CHANGE SPEED TIMER OR SLIDER 			-- END --

func _on_time_slider_drag_started() -> void:
	is_dragging_time_slider = true
	time_text.text = (str(time_slider.value) + "%")
	song.stop()
	_song_finished = false
	
	_adjust_time_pos_text(true)

func _on_time_slider_drag_ended(value_changed: bool) -> void:
	is_dragging_time_slider = false
	time_text.text = (str(time_slider.value) + "%")
	last_pseudo_valid_time_text = time_text.text
	
	_adjust_time_pos_text(true)
	
	_song_finished = time_slider.value == 100.0
	if _song_finished:
		$Play.text = "Play"
		song.stop()
		_temp_song_time_pos = 0.0
	else:
		_temp_song_time_pos = song.stream.get_length() * time_slider.value / 100
		if $Play.text == "Pause": # IT'S PLAYING
			song.play(_temp_song_time_pos)
	

func _on_time_percentage_text_changed() -> void:
	if "\n" in time_text.text:
		time_text.text = time_text.text.replace("\n", "")
		time_text.release_focus()
	if "-" in time_text.text:
		time_text.text = time_text.text.replace("-", "")
		time_text.release_focus()
	if not ("" == time_text.text or "%" == time_text.text or "." == time_text.text):
		var text = ""
		if (time_text.text.length() > 1 and time_text.text.ends_with(".")) or (
			time_text.text.length() > 2 and time_text.text.ends_with(".%")):
				text = time_text.text.replace(".", ".0")
		elif (time_text.text.length() == 1 and time_text.text.ends_with(".")) or (
			time_text.text.length() == 2 and time_text.text.ends_with(".%")):
			text = time_text.text.replace(".", "0.0")
		else:
			text = time_text.text
		if not is_time_text_valid(text):
			var idx = time_text.get_caret_column()
			var difference = abs(time_text.text.length() - last_pseudo_valid_time_text.length())
			time_text.text = last_pseudo_valid_time_text
			time_text.set_caret_column(idx - difference)
		else:
			#if time_text.text.ends_with(".") or time_text.text.ends_with(".%"):
				#time_text.text = time_text.text.replace(".", ".0")
			var str = get_float_number.search(text).strings[0]
			if str.begins_with("."):
				str = "0" + str
			var value = str_to_var(str)
			if value < time_slider.min_value:
				time_slider.value = time_slider.min_value
			elif value > time_slider.max_value:
				time_slider.value = time_slider.max_value
			else:
				time_slider.value = value
		last_time_value = time_slider.value
		last_pseudo_valid_time_text = time_text.text
		return

func _on_time_percentage_focus_exited() -> void:
	adjust_time()

func is_time_text_valid(str : String) -> bool:
	var is_valid_1 = valid_time_with_perc.search(str)
	var is_valid_2 = valid_time.search(str)
	return is_valid_1 or is_valid_2

func adjust_time() -> void:
	var text = ""
	if (time_text.text.length() > 1 and time_text.text.ends_with(".")) or (
		time_text.text.length() > 2 and time_text.text.ends_with(".%")):
			text = time_text.text.replace(".", ".0")
	elif (time_text.text.length() == 1 and time_text.text.ends_with(".")) or (
		time_text.text.length() == 2 and time_text.text.ends_with(".%")):
		text = time_text.text.replace(".", "0.0")
	else:
		text = time_text.text
	if is_time_text_valid(text):
		if time_text.text.ends_with(".") or time_text.text.ends_with(".%"):
			time_text.text = time_text.text.replace(".", "")
		var str = get_float_number.search(text).strings[0]
		if str.begins_with("."):
			str = "0" + str
		var value = str_to_var(str)
		if value < time_slider.min_value:
			time_slider.value = time_slider.min_value
		elif value > time_slider.max_value:
			time_slider.value = time_slider.max_value
		else:
			time_slider.value = value
		time_text.text = str(time_slider.value) + "%" # CORRECTS THE VALUE, IN CASE ENTERS IN THE FIRST TWO CONDITIONS
		last_valid_time_text = time_text.text
	else:
		time_text.text = last_valid_time_text
	time_text.release_focus()

func _on_play_pressed() -> void:
	if $Play.text == "Play": #PLAY
		$Play.text = "Pause"
		song.play(_temp_song_time_pos)
		_song_finished = false
	elif $Play.text == "Pause": #PAUSE
		$Play.text = "Play"
		_temp_song_time_pos = song.get_playback_position()
		song.stop()

func _song_has_finished() -> void:
	_song_finished = true
	_temp_song_time_pos = 0.0
	$Play.text = "Play"

func _adjust_time_pos_text(split_time_by_temp_time : bool = false) -> void:
	if split_time_by_temp_time:
		var splitted_time = split_time(_temp_song_time_pos)
		time_pos_text.text = "%02d:%02d:%03d" % [splitted_time["minutes"], splitted_time["seconds"], splitted_time["milliseconds"]]
		return
	
	var splitted_time = split_time(song.get_playback_position())
	time_pos_text.text = "%02d:%02d:%03d" % [splitted_time["minutes"], splitted_time["seconds"], splitted_time["milliseconds"]]

func split_time(total_seconds: float) -> Dictionary:
	var minutes = int(total_seconds) / 60
	var seconds = int(total_seconds) % 60
	var milliseconds = int((total_seconds - int(total_seconds)) * 1000)
	return {
		"minutes": minutes,
		"seconds": seconds,
		"milliseconds": milliseconds
	}

func _on_time_text_changed(force_change : bool = false) -> void:
	if "\n" in time_pos_text.text or force_change:
		time_pos_text.text = time_pos_text.text.replace("\n", "")
		valid_time_pos.search(time_pos_text.text)
		var values := time_pos_text.text.split(":")
		var minutes : int = str_to_var(values[0])
		var seconds : int = str_to_var(values[1])
		var miliseconds : float = str_to_var("0." + values[2])
		var absolute_seconds : float = minutes * 60 + seconds + miliseconds
		_temp_song_time_pos = absolute_seconds
		time_pos_text.release_focus()

func _on_time_focus_entered() -> void:
	if $Play.text == "Pause":
		$Play.text = "Play"
		song.stop()
		song_was_playing = true

func _on_time_focus_exited() -> void:
	_on_time_text_changed(true)
	if song_was_playing:
		$Play.text = "Pause"
		song.play(_temp_song_time_pos)
		song_was_playing = false

func _on_stop_pressed() -> void:
	_temp_song_time_pos = 0.0
	$Play.text = "Play"
	song.stop()
	time_slider.value = 0.0
	_on_time_slider_drag_ended(false)
	#_adjust_time_pos_text()

func get_time_pos() -> float:
	if $Play.text == "Pause":
		return song.get_playback_position()
	return _temp_song_time_pos
