extends Control

class_name MusicPlayer

#@export var _song_resource_path : String
@export var autoload : bool = true
@export var _gear_type : Gear.Type = Gear.Type.FOUR_KEYS
@export var _difficulty : SongMap.Difficulty
@export var _gear_skin_scene : PackedScene
var _gear_skin : GearSkin
#var _song_resource : SongResource

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

var _current_fever_score : float = 0.0
var _perfect_state : bool = true

var _current_combo : int = 0

var fade_tween : Tween

var _section_dict : Dictionary
const DEFAULT_SECTION_TITLE : String = "<\\DEFAULT_VALUE\\>"
var _current_section_title : String

var _fade_out_reseted : bool = true

var _current_uuid : String = ""

signal game_started

signal quit_request

func _ready() -> void:
	Global.main_music_player = self
	
	Global.speed_changed.connect(_speed_changed)
	
	set_process(false)
	
	resized.connect(_resized)
	
	_pause_screen.resume_pressed.connect(pause)
	_pause_screen.restart_pressed.connect(restart)
	_pause_screen.quit_pressed.connect(_quit)
	
	if autoload:
		Gear.set_speed(Game.speed)
		Game.load_music_player(self)
		_pause_screen.quit_pressed.connect(Game.change_to_selection)

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
		game_started.emit()
		if video.stream and Global.get_settings_dictionary()["video"]:
			if video.paused:
				video.paused = false
			video.play() ## THIS USES A BUNCH OF FPS!
		
		Song.pitch_scale = 1.0
		Song.play()
		set_process(false)

func start() -> void:
	if not World.environment:
		World.load_glow_environment()
	_fade_out_reseted = true
	_current_uuid = Global.get_UUID()
	_section_dict.clear()
	_current_section_title = DEFAULT_SECTION_TITLE
	_section_dict[_current_section_title] = _default_precision_dictionary()
	_perfect_state = true
	_current_combo = 0
	_gear_skin.set_combo(0)
	set_process(true)
	Song.stream_paused = false
	_current_time = 0.0
	_pause_screen.visible = false
	_gear.set_max_size_y(size.y)
	NoteHolder.set_hitzone(-325)

func _create_gear() -> void:
	current_score = 0.0
	_current_fever_score = 0.0
	
	if _gear_skin:
		remove_child(_gear_skin)
		_gear_skin.queue_free()
	
	_gear_skin = _gear_skin_scene.instantiate()
	add_child(_gear_skin)
	
	if _gear:
		remove_child(_gear)
		_gear.queue_free()
	
	_gear = Gear.new(_gear_type, Gear.Mode.PLAYER, false, size.y)
	_gear.last_note_was_processed.connect(_last_note_was_processed)
	_gear.section_changed.connect(_gear_section_changed)
	_gear.fade_out.connect(_gear_fade_out)
	_gear.fade_in.connect(_gear_fade_in)
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
	Song.stop()
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
		if long_note.type == LongNote.Type.ANNOTATION:
			continue
		_gear.add_long_note(long_note.to_long_note())
	_count_value_of_notes()

func restart() -> void:
	Game.restarted()
	_current_time = 0.0
	Song.stop()
	Song.set_time(0.0)
	if video.stream:
		video.stop()
	_create_gear()
	start()

func pause() -> void:
	_holding_time = 0.0
	if _current_time < TIME_TO_START:
		_pause_screen.visible = not _pause_screen.visible
		set_process(not is_processing())
		return
	Song.stream_paused = not _pause_screen.visible
	#if video.stream and Global.get_settings_dictionary()["video"]:
		#video.paused = not _pause_screen.visible # NOTE The get_tree().paused already works at the video
	_pause_screen.visible = not _pause_screen.visible

func _quit() -> void:
	Game.restarted()
	Song.set_time(0)
	Song.stop()
	World.unload()
	quit_request.emit()

func reset() -> void:
	if video:
		video.stop()
	video.stream = null
	image.texture = null

func _gear_section_changed(title : String) -> void:
	_current_section_title = title
	_section_dict[_current_section_title] = _default_precision_dictionary()
	
func _gear_fade_out() -> void:
	_fade_out_reseted = false
	if _current_time < TIME_TO_START:
		await game_started
		if _fade_out_reseted:
			return
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(_gear_skin, "modulate:a", 0.0, 1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	
	fade_tween.parallel().tween_property(_gear, "modulate:a", 0.0, 1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)

func _gear_fade_in() -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.tween_property(_gear_skin, "modulate:a", 1.0, 1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)
	fade_tween.parallel().tween_property(_gear, "modulate:a", 1, 1) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN)

func _default_precision_dictionary() -> Dictionary:
	return {"100": 0,
			"90": 0,
			"80": 0,
			"70": 0,
			"60": 0,
			"50": 0,
			"40": 0,
			"30": 0,
			"20": 0,
			"10": 0,
			"1": 0,
			"0": 0}

func _count_value_of_notes() -> void:
	var notes_size : float = _gear.get_all_notes().size()
	_value_of_note = MusicPlayer.MAXIMUM_SCORE / notes_size

static func get_value_of_note() -> float:
	return _value_of_note

static func get_current_time() -> float:
	return _current_time

func pop_precision(precision : int) -> void:
	_gear_skin.pop_precision(precision)
	_calculate_fever(precision)

func _calculate_fever(precision : int) -> void:
	_register_precision_in_section_dict(precision)
	if precision == 0:
		_perfect_state = true
		_gear_skin.set_combo(0)
		_current_combo = 0
		_current_fever_score = 0
		_gear_skin.set_fever_value(_current_fever_score, Note.Fever.NONE)
		return
	
	_current_fever_score += Note.FEVER_VALUE * abs(precision) / 100.0
	
	if precision != 100:
		_perfect_state = false
	
	if _current_fever_score >= 0.0 and _current_fever_score < Note.Fever.X1: ## NONE
		_gear_skin.set_fever_value(Global.get_percentage_between(0.0, Note.Fever.X1, _current_fever_score) * 100, Note.Fever.X1)
		_current_combo += 1
	elif _current_fever_score >= Note.Fever.X1 and _current_fever_score < Note.Fever.X2: ## 1X
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X1, Note.Fever.X2, _current_fever_score) * 100, Note.Fever.X2)
		_current_combo += 1
	elif _current_fever_score >= Note.Fever.X2 and _current_fever_score < Note.Fever.X3: ## 2X
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X2, Note.Fever.X3, _current_fever_score) * 100, Note.Fever.X3)
		_current_combo += 2
	elif _current_fever_score >= Note.Fever.X3 and _current_fever_score < Note.Fever.X4: ## 3X
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X3, Note.Fever.X4, _current_fever_score) * 100, Note.Fever.X4)
		_current_combo += 3
	elif _current_fever_score >= Note.Fever.X4 and _current_fever_score < Note.Fever.X5: ## 4X
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X4, Note.Fever.X5, _current_fever_score) * 100, Note.Fever.X5)
		_current_combo += 4
	elif _current_fever_score >= Note.Fever.X5 and _current_fever_score < Note.Fever.ZONE: ## 5X
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X5, Note.Fever.ZONE, _current_fever_score) * 100, Note.Fever.ZONE)
		_current_combo += 5
	elif _current_fever_score >= Note.Fever.ZONE and _current_fever_score < Note.Fever.MAX_ZONE: ## ZONE
		if not _perfect_state: ## RETURNS TO 5X
			_current_fever_score = Note.Fever.X5 + (_current_fever_score - Note.Fever.ZONE)
			_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.X5, Note.Fever.ZONE, _current_fever_score) * 100, Note.Fever.ZONE, true, _gear_skin._current_fever == Note.Fever.MAX_ZONE)
			_current_combo += 5
		else:
			_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.ZONE, Note.Fever.MAX_ZONE, _current_fever_score) * 100, Note.Fever.MAX_ZONE)
			_current_combo += 10
		_perfect_state = true
	elif _current_fever_score >= Note.Fever.MAX_ZONE:
		_current_fever_score = Note.Fever.ZONE + (_current_fever_score - Note.Fever.MAX_ZONE)
		_gear_skin.set_fever_value(Global.get_percentage_between(Note.Fever.ZONE, Note.Fever.MAX_ZONE, _current_fever_score) * 100, Note.Fever.MAX_ZONE, true)
	
	_gear_skin.set_combo(_current_combo)

func _register_precision_in_section_dict(precision : int) -> void:
	precision = abs(precision)
	_section_dict[_current_section_title][str(precision)] += 1

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

func _last_note_was_processed() -> void:
	#print(_section_dict)
	#print("foi")
	var perfect : bool = true
	for section in _section_dict.values():
		if _section_has_break(section):
			_gear_skin.play_finalization(GearSkin.Finalization.CLEAR)
			perfect = false
			break
		elif _section_has_not_perfect_precision(section):
			_gear_skin.play_finalization(GearSkin.Finalization.MAX_COMBO)
			perfect = false
			break
	if perfect:
		_gear_skin.play_finalization(GearSkin.Finalization.PERFECT_COMBO)
	if autoload:
		wait_for_song_to_finish(_current_uuid)

func wait_for_song_to_finish(id : String) -> void:
	#print("to perando")
	if not Song.is_finished():
		await Song.finished
	#print(id)
	#print(_current_uuid)
	if self and id == _current_uuid:
		World.unload()
		Game.game_ended.emit(current_score, _current_combo, _section_dict)

func _section_has_break(section : Dictionary) -> bool:
	return section["0"] > 0

func _section_has_not_perfect_precision(section : Dictionary) -> bool:
	return (section["90"] > 0 or section["80"] > 0 or section["70"] > 0 or section["60"] > 0
		 or section["50"] > 0 or section["40"] > 0 or section["30"] > 0 or section["20"] > 0
		 or section["10"] > 0 or section["1"] > 0)

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
