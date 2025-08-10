extends AudioStreamPlayer

class_name Song

static var _current_time : float = 0.0

static var _song_finished : bool = false

static var _duration : float = 0.0

func _ready() -> void:
	finished.connect(_finished)
	_duration = stream.get_length()

func _physics_process(delta: float) -> void:
	if _song_finished:
		_song_finished = false
	
	if playing:
		_current_time = get_playback_position()

func _finished() -> void:
	_song_finished = true

func set_time(time : float) -> void:
	seek(time)
	_current_time = time

static func get_time() -> float:
	return _current_time

static func is_song_finished() -> bool:
	return _song_finished

static func get_duration() -> float:
	return _duration
