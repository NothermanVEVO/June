extends AudioStreamPlayer

var _current_time : float = 0.0

var _song_finished : bool = false

var _duration : float = 0.0

var BPM : int = 0

func _ready() -> void:
	finished.connect(_finished)
	bus = &"Song"

func _process(_delta: float) -> void:
	
	if playing:
		_song_finished = false
		_current_time = get_playback_position()

func _finished() -> void:
	set_time(get_duration())
	_song_finished = true

@warning_ignore("shadowed_variable_base_class")
func set_song(stream : AudioStream) -> void:
	self.stream = stream
	_duration = stream.get_length()

func set_time(time : float) -> void:
	seek(time)
	_current_time = time

func get_time() -> float:
	return _current_time

func is_finished() -> bool:
	return _song_finished

func get_duration() -> float:
	return _duration
