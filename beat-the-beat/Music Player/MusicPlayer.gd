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

var song_map : SongMap
var song_stream : AudioStream
var video_stream : VideoStream
var image_texture : ImageTexture

var _gear : Gear

static var _current_time : float = 0.0
const TIME_TO_START : float = 4.0

const MAXIMUM_SCORE : int = 1000000
var current_score : float = 0.0

static var _value_of_note : float

func _ready() -> void:
	_gear_skin = _gear_skin_scene.instantiate()
	add_child(_gear_skin)
	
	resized.connect(_resized)
	_gear = Gear.new(Gear.Type.FOUR_KEYS, Gear.Mode.PLAYER, false, size.y)
	Gear.set_speed(5)
	set_speed(Gear.get_speed())
	add_child(_gear)
	_gear.set_hitzone(-325)
	_gear.position.x = size.x / 2
	_gear.position.y = size.y
	
	if _song_resource_path:
		_load_song_resource(_song_resource_path)
	_load_song_map()
	
	Global.main_music_player = self
	
	Global.speed_changed.connect(_speed_changed)

func _resized() -> void:
	_gear.set_max_size_y(size.y)
	_gear.position.x = size.x / 2
	_gear.position.y = size.y

func _speed_changed() -> void:
	set_speed(Gear.get_speed())

func _process(_delta: float) -> void:
	_current_time += _delta
	if _current_time >= TIME_TO_START:
		Song.play()
		video.play() ## THIS USES A BUNCH OF FPS!
		set_process(false)

func _load_song_resource(path : String):  ##TODO MAKE A BETTER THING HERE TO RETURN FROM THE GAME ## I WAS PROBABLY MEANING A ERROR MESSAGE
	if not FileAccess.file_exists(path):
		print("Arquivo não existe")
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var result = json.parse(content)
	if result == OK:
		var json_data = json.get_data()
		var validate_wrong = SongResource.validate_dictionary(json_data)
		if validate_wrong:
			print("Formato inválido de arquivo")
			return
		else:
			_song_resource = SongResource.dictionary_to_resource(json_data)
			if _song_resource.song:
				song_stream = Loader.load_music_stream(_song_resource.song)
				Song.set_song(song_stream)
			if _song_resource.video:
				video_stream = Loader.load_video_stream(_song_resource.video)
				video.stream = video_stream
			elif _song_resource.image:
				image_texture = Loader.load_image(_song_resource.image)
				image.texture = image_texture

func _load_song_map() -> void:
	if not _song_resource:
		print("n foi song resource")
		return
	if not _gear:
		print("N foi _gear")
		return
	for s_map in _song_resource.song_maps:
		if s_map.difficulty == _difficulty and s_map.gear_type == _gear_type:
			print("achou")
			song_map = s_map
			break
	for note in song_map.notes:
		_gear.add_note_at(note.idx, note.to_note(Gear.Mode.PLAYER))
	for long_note in song_map.long_notes:
		_gear.add_long_note(long_note.to_long_note())
	_count_value_of_notes()

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
	_gear_skin.set_speed(speed)

func add_score(score : float) -> void:
	current_score += score
	_set_score(roundi(current_score))

func _set_score(score : int) -> void:
	_gear_skin.set_score(score)

func _draw() -> void:
	draw_circle(get_viewport_rect().size / 2, 5, Color.BLACK)
