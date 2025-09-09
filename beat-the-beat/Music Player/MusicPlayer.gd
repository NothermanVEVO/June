extends Control

class_name MusicPlayer

@export var _song_resource_path : String
var _song_resource : SongResource

@onready var video : VideoStreamPlayer = $VideoStreamPlayer
@onready var image : TextureRect = $TextureRect

var song_map : SongMap
var song_stream : AudioStream
var video_stream : VideoStream
var image_texture : ImageTexture

var _gear : Gear

func _ready() -> void:
	if _song_resource_path:
		load_song_resource(_song_resource_path)
	Song.play()
	video.play()
	_gear = Gear.new(Gear.Type.FOUR_KEYS, Gear.Mode.EDITOR, false, size.y)
	add_child(_gear)
	_gear.position.x = size.x / 2
	_gear.position.y = size.y
	# TEMP ===========
	#_gear = Gear.new(Gear.Type.SIX_KEYS)
	#add_child(_gear)
	# TEMP ===========
	pass

func _physics_process(_delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#_gear.add_note_at(0)
	pass

func load_song_resource(path : String):  ##TODO MAKE A BETTER THING HERE TO RETURN FROM THE GAME
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

func _draw() -> void:
	draw_circle(get_viewport_rect().size / 2, 5, Color.BLACK)
