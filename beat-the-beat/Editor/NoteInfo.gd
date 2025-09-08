extends PanelContainer

class_name NoteInfo

@onready var _start_time : TextEdit = $"MarginContainer/InfoVBox/Start/Start Time"
@onready var _end_time : TextEdit = $"MarginContainer/InfoVBox/End/End Time"
##@onready var _sfx : TextEdit = $MarginContainer/InfoVBox/SFX #WARNING UNUSED
##@onready var _locked : CheckBox = $MarginContainer/InfoVBox/Locked #WARNING UNUSED
@onready var _power : CheckBox = $MarginContainer/InfoVBox/Power

@onready var _end_time_container : FlowContainer = $MarginContainer/InfoVBox/End

enum Type{TAP, HOLD}

var _last_valid_start_time := ""
var _last_valid_start_time_before_change := ""

var _last_valid_end_time := ""
var _last_valid_end_time_before_change := ""

signal valid_start_time_text_change(seconds : float)
signal valid_end_time_text_change(seconds : float)

signal power_changed(value : bool)

func _ready() -> void:
	z_index = 2

func set_type(type : Type) -> void:
	match type:
		Type.TAP:
			_end_time_container.visible = false
		Type.HOLD:
			_end_time_container.visible = true

func set_start_time(start_time : float) -> void:
	var splitted_time := SoundBoard.split_time(start_time)
	_start_time.text = "%02d:%02d:%03d" % [splitted_time["minutes"], splitted_time["seconds"], splitted_time["milliseconds"]]
	_last_valid_start_time = _start_time.text
	_last_valid_start_time_before_change = _start_time.text

func set_end_time(end_time : float) -> void:
	var splitted_time := SoundBoard.split_time(end_time)
	_end_time.text = "%02d:%02d:%03d" % [splitted_time["minutes"], splitted_time["seconds"], splitted_time["milliseconds"]]
	_last_valid_end_time = _end_time.text
	_last_valid_end_time_before_change = _end_time.text

func set_power_value(value : bool) -> void:
	_power.button_pressed = value

func _on_start_time_text_changed() -> void:
	var pressed_enter := false
	if "\n" in _start_time.text:
		pressed_enter = true
		_start_time.text = _start_time.text.replace("\n", "")
		var values := _start_time.text.split(":")
		if values.size() == 3:
			set_start_time(_get_time_in_seconds(_start_time))
		else:
			_start_time.text = _last_valid_start_time
		_last_valid_start_time_before_change = _start_time.text
		_start_time.release_focus()
	
	var result := SoundBoard.outlimits_valid_time_pos.search(_start_time.text)
	if result:
		_last_valid_start_time = _start_time.text
		if not pressed_enter:
			valid_start_time_text_change.emit(_get_time_in_seconds(_start_time))

func _on_end_time_text_changed() -> void:
	var pressed_enter := false
	if "\n" in _end_time.text:
		pressed_enter = true
		_end_time.text = _end_time.text.replace("\n", "")
		var values := _end_time.text.split(":")
		if values.size() == 3:
			set_end_time(_get_time_in_seconds(_end_time))
		else:
			_end_time.text = _last_valid_end_time
		_last_valid_end_time_before_change = _end_time.text
		_end_time.release_focus()
	
	var result := SoundBoard.outlimits_valid_time_pos.search(_end_time.text)
	if result:
		_last_valid_end_time = _end_time.text
		if not pressed_enter:
			valid_end_time_text_change.emit(_get_time_in_seconds(_end_time))

func _on_locked_pressed() -> void:
	pass # Replace with function body.

func _on_power_pressed() -> void:
	power_changed.emit(_power.button_pressed)

func _on_start_time_focus_exited() -> void:
	_start_time.text = _last_valid_start_time_before_change
	valid_start_time_text_change.emit(_get_time_in_seconds(_start_time))

func _on_end_time_focus_exited() -> void:
	_end_time.text = _last_valid_end_time_before_change
	valid_end_time_text_change.emit(_get_time_in_seconds(_end_time))

func _get_time_in_seconds(textEdit : TextEdit) -> float:
	var values := textEdit.text.split(":")
	values[0] = "00" if not values[0] else "0" + values[0] if values[0].length() == 1 else values[0]
	values[1] = "00" if not values[1] else "0" + values[1] if values[1].length() == 1 else values[1]
	values[2] = "000" if not values[2] else values[2] + "00" if values[2].length() == 1 else values[2] + "0" if values[2].length() == 2 else values[2]
			
	var minutes : int = str_to_var(values[0])
	var seconds : int = str_to_var(values[1])
	var miliseconds : float = str_to_var("0." + values[2])
	var absolute_seconds : float = minutes * 60 + seconds + (miliseconds + 0.0005) # !!BUG!! THE DECIMAL NUMBER DECREASES IN 0.001, AND INCREASES IN 0.0001 WHEN PUTTING MORE THAN 3 NUMBER IN THE DECIMAL, SOLVE THIS LATER
	absolute_seconds = absolute_seconds if absolute_seconds <= Song.get_duration() else Song.get_duration()
	return absolute_seconds

func has_mouse() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())
