extends Control

class_name MusicPlayer

@export var _song_resource_path : String
@export var _gear_type : Gear.Type = Gear.Type.FOUR_KEYS
@export var _difficulty : SongMap.Difficulty
@export var _gear_skin_scene : PackedScene
var _gear_skin : GearSkin
var _song_resource : SongResource

@onready var video : VideoStreamPlayer = $VideoStreamPlayer
@onready var image : TextureRect = $TextureRect

@onready var _pause_screen : PauseScreen = $PauseScreen

var _song_map : SongMap
var song_stream : AudioStream
var video_stream : VideoStream
var image_texture : ImageTexture

var _gear : Gear

static var _current_time : float = 0.0
const TIME_TO_START : float = 4.0

const MAXIMUM_SCORE : int = 1000000
var current_score : float = 0.0

static var _value_of_note : float

var _holding_time : float = 0.0
const _HOLDING_DELAY : float = 0.30

signal quit_request

func _ready() -> void:
	Global.main_music_player = self
	
	Global.speed_changed.connect(_speed_changed)
	
	set_process(false)
	
	resized.connect(_resized)
	
	_pause_screen.resume_pressed.connect(pause)
	_pause_screen.restart_pressed.connect(restart)
	_pause_screen.quit_pressed.connect(_quit)

func _resized() -> void:
	if _gear:
		_gear.set_max_size_y(size.y)
		_gear.position.x = size.x / 2
		_gear.position.y = size.y

func _speed_changed() -> void:
	set_speed(Gear.get_speed())

func _physics_process(delta: float) -> void:
	if not visible:
		_holding_time = 0.0
		return
	if Input.is_action_just_pressed("Escape"):
		_holding_time = 0.0
		pause()
	elif Input.is_action_just_pressed("Restart"):
		_holding_time = 0.0
		restart()
	if not _pause_screen.visible:
		if Input.is_action_just_pressed("Decrease Speed"):
			Gear.set_speed(clampf(Gear.get_speed() - 0.1, 1.0, 10.0))
		elif Input.is_action_just_pressed("Increase Speed"):
			Gear.set_speed(clampf(Gear.get_speed() + 0.1, 1.0, 10.0))
		elif Input.is_action_pressed("Decrease Speed") and not _pause_screen.visible:
			_holding_time += delta
			if _holding_time >= _HOLDING_DELAY:
				_holding_time -= _HOLDING_DELAY / 4
				Gear.set_speed(clampf(Gear.get_speed() - 0.1, 1.0, 10.0))
		elif Input.is_action_pressed("Increase Speed"):
			_holding_time += delta
			if _holding_time >= _HOLDING_DELAY:
				_holding_time -= _HOLDING_DELAY / 4
				Gear.set_speed(clampf(Gear.get_speed() + 0.1, 1.0, 10.0))
	if Input.is_action_just_released("Decrease Speed") or Input.is_action_just_released("Increase Speed"):
		_holding_time = 0.0

func _process(_delta: float) -> void:
	_current_time += _delta
	if _current_time >= TIME_TO_START:
		if video.stream and Global.get_settings_dictionary()["video"]:
			if video.paused:
				video.paused = false
			video.play() ## THIS USES A BUNCH OF FPS!
		
		if Song.stream_paused:
			Song.stream_paused = false
		Song.pitch_scale = 1.0
		Song.play()
		set_process(false)

func start() -> void:
	set_process(true)
	_current_time = 0.0
	_pause_screen.visible = false
	_gear.set_max_size_y(size.y)
	NoteHolder.set_hitzone(-325)

func _create_gear() -> void:
	current_score = 0.0
	
	if _gear_skin:
		remove_child(_gear_skin)
		_gear_skin.queue_free()
	
	_gear_skin = _gear_skin_scene.instantiate()
	add_child(_gear_skin)
	
	if _gear:
		remove_child(_gear)
		_gear.queue_free()
	
	_gear = Gear.new(_gear_type, Gear.Mode.PLAYER, false, size.y)
	set_speed(Gear.get_speed())
	add_child(_gear)
	move_child(_pause_screen, get_child_count() - 1)
	_gear.position.x = size.x / 2
	_gear.position.y = size.y
	_load_song_map()

@warning_ignore("shadowed_variable")
func load_by_vars(gear_type : Gear.Type, song_map : SongMap, song, video_stream = null, texture = null) -> void:
	_gear_type = gear_type
	_song_map = song_map
	Song.set_song(song)
	Song.set_time(0.0)
	_create_gear()
	if Global.get_settings_dictionary()["video"]:
		video.stream = video_stream
	if not video.stream:
		image.texture = texture

func _load_song_map() -> void:
	if not _song_map or _song_map.gear_type != _gear_type:
		print("deu merda")
		return
	for note in _song_map.notes:
		_gear.add_note_at(note.idx, note.to_note(Gear.Mode.PLAYER))
	for long_note in _song_map.long_notes:
		_gear.add_long_note(long_note.to_long_note())
	_count_value_of_notes()

func restart() -> void:
	_current_time = 0.0
	Song.stop()
	Song.set_time(0.0)
	if video.stream:
		video.stop()
	_create_gear()
	start()

func pause() -> void:
	_pause_screen.visible = not _pause_screen.visible
	if _current_time < TIME_TO_START:
		set_process(not is_processing())
		return
	Song.stream_paused = not Song.stream_paused
	if video.stream and Global.get_settings_dictionary()["video"]:
		video.paused = not video.paused

func _quit() -> void:
	Song.set_time(0)
	quit_request.emit()

func reset() -> void:
	if video:
		video.stop()
	video.stream = null
	image.texture = null

func _count_value_of_notes() -> void:
	var notes_size : float = _gear.get_all_notes().size()
	_value_of_note = MusicPlayer.MAXIMUM_SCORE / notes_size

static func get_value_of_note() -> float:
	return _value_of_note

static func get_current_time() -> float:
	return _current_time

func pop_precision(precision : int) -> void:
	_gear_skin.pop_precision(precision)

func set_speed(speed : float) -> void:
	if _gear_skin:
		_gear_skin.set_speed(speed)

func add_score(score : float) -> void:
	current_score += score
	_set_score(roundi(current_score))

func _set_score(score : int) -> void:
	_gear_skin.set_score(score)

func _draw() -> void:
	draw_circle(get_viewport_rect().size / 2, 5, Color.BLACK)

#func load_by_path(path : String):  ##TODO MAKE A BETTER THING HERE TO RETURN FROM THE GAME ## I WAS PROBABLY MEANING A ERROR MESSAGE
	#if not FileAccess.file_exists(path):
		#print("Arquivo não existe")
		#return
	#
	#var file := FileAccess.open(path, FileAccess.READ)
	#var content := file.get_as_text()
	#file.close()
	#
	#var json := JSON.new()
	#var result = json.parse(content)
	#if result == OK:
		#var json_data = json.get_data()
		#var validate_wrong = SongResource.validate_dictionary(json_data)
		#if validate_wrong:
			#print("Formato inválido de arquivo")
			#return
		#else:
			#_song_resource = SongResource.dictionary_to_resource(json_data)
			#if _song_resource.song:
				#song_stream = Loader.load_music_stream(_song_resource.song)
				#Song.set_song(song_stream)
			#if _song_resource.video:
				#video_stream = Loader.load_video_stream(_song_resource.video)
				#video.stream = video_stream
			#elif _song_resource.image:
				#image_texture = Loader.load_image(_song_resource.image)
				#image.texture = image_texture
	#_load_song_map()
