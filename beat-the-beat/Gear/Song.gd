extends AudioStreamPlayer

class_name Song

static var _current_time : float = 0.0

static var _song_finished : bool = false

func _ready() -> void:
	finished.connect(_finished)

func _physics_process(delta: float) -> void:
	if _song_finished:
		_song_finished = false
	
	if playing:
		_current_time = get_playback_position()
	#print(_current_time)

func _finished() -> void:
	_song_finished = true

func set_time(time : float) -> void:
	seek(time)
	_current_time = time

static func get_time() -> float:
	return _current_time

static func is_song_finished() -> bool:
	return _song_finished
