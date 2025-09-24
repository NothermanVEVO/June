extends TabBar

class_name TabButton

@export var gear_type : Gear.Type

@onready var image : TextureRect = $MarginContainer/VBoxContainer/Image
@onready var song_name : RichTextLabel = $MarginContainer/VBoxContainer/SongName
@onready var author_name : RichTextLabel = $MarginContainer/VBoxContainer/AuthorName
@onready var creator_name : RichTextLabel = $MarginContainer/VBoxContainer/CreatorName
@onready var bpm : RichTextLabel = $MarginContainer/VBoxContainer/BPM

@onready var facil : Button = $MarginContainer/VBoxContainer/Difficulties/Facil
@onready var normal : Button = $MarginContainer/VBoxContainer/Difficulties/Normal
@onready var hard : Button = $MarginContainer/VBoxContainer/Difficulties/Hard
@onready var maximus : Button = $MarginContainer/VBoxContainer/Difficulties/Maximus

@onready var score : RichTextLabel = $MarginContainer/VBoxContainer/Score
@onready var combo : RichTextLabel = $MarginContainer/VBoxContainer/Combo

@onready var state_text : RichTextLabel = $MarginContainer/VBoxContainer/State/StateText
@onready var state_image : TextureRect = $MarginContainer/VBoxContainer/State/TextureRect

@onready var settings : Button = $MarginContainer/VBoxContainer/Settings

var _last_difficulty_button : Button

signal load_difficulty_save(difficulty : SongMap.Difficulty)
signal play_difficulty(difficulty : SongMap.Difficulty)

func _on_focus_entered() -> void:
	facil.grab_focus()

func set_song_resource(song_resource : SongResource) -> void:
	reset()
	image.texture = Loader.load_image(song_resource.image)
	song_name.text = song_resource.name
	author_name.text = "Autor: " + song_resource.author
	creator_name.text = "Criado por: " + song_resource.creator
	bpm.text = "BPM: " + str(song_resource.BPM)
	
	for song_map in song_resource.song_maps:
		if song_map.difficulty == SongMap.Difficulty.FACIL and song_map.gear_type == gear_type:
			facil.text = "Facil\n " + str(song_map.stars)
			facil.disabled = false
		elif song_map.difficulty == SongMap.Difficulty.NORMAL and song_map.gear_type == gear_type:
			normal.text = "Normal\n " + str(song_map.stars)
			normal.disabled = false
		elif song_map.difficulty == SongMap.Difficulty.HARD and song_map.gear_type == gear_type:
			hard.text = "Hard\n " + str(song_map.stars)
			hard.disabled = false
		elif song_map.difficulty == SongMap.Difficulty.MAXIMUS and song_map.gear_type == gear_type:
			maximus.text = "Maximus\n " + str(song_map.stars)
			maximus.disabled = false
	
	if not facil.disabled:
		facil.button_pressed = true
		_last_difficulty_button = facil
		if visible:
			load_difficulty_save.emit(SongMap.Difficulty.FACIL)
	elif not normal.disabled:
		normal.button_pressed = true
		_last_difficulty_button = normal
		if visible:
			load_difficulty_save.emit(SongMap.Difficulty.NORMAL)
	elif not hard.disabled:
		hard.button_pressed = true
		_last_difficulty_button = hard
		if visible:
			load_difficulty_save.emit(SongMap.Difficulty.HARD)
	elif not maximus.disabled:
		maximus.button_pressed = true
		_last_difficulty_button = maximus
		if visible:
			load_difficulty_save.emit(SongMap.Difficulty.MAXIMUS)
	
	score.text = "Pontuação: "
	combo.text = "Combo: "

func reset() -> void:
	image.texture = null
	song_name.text = ""
	author_name.text = ""
	creator_name.text = ""
	bpm.text = ""
	facil.text = "Facil\n "
	normal.text = "Normal\n "
	hard.text = "Hard\n "
	maximus.text = "Maximus\n "
	score.text = ""
	combo.text = ""
	state_text.text = ""
	state_image.texture = null
	
	facil.disabled = true
	facil.button_pressed = false
	
	normal.disabled = true
	normal.button_pressed = false
	
	hard.disabled = true
	hard.button_pressed = false
	
	maximus.disabled = true
	maximus.button_pressed = false

func _process(delta: float) -> void:
	if facil.has_focus():
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("Add Item") and 
		facil.get_global_rect().has_point(get_global_mouse_position())):
			if not facil.button_pressed and not facil.disabled:
				facil.button_pressed = true
				_last_difficulty_button.button_pressed = false
				_last_difficulty_button = facil
				load_difficulty_save.emit(SongMap.Difficulty.FACIL)
			else:
				play_difficulty.emit(SongMap.Difficulty.FACIL)
	elif normal.has_focus():
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("Add Item") and 
		normal.get_global_rect().has_point(get_global_mouse_position())):
			if not normal.button_pressed and not normal.disabled:
				normal.button_pressed = true
				_last_difficulty_button.button_pressed = false
				_last_difficulty_button = normal
				load_difficulty_save.emit(SongMap.Difficulty.NORMAL)
			else:
				play_difficulty.emit(SongMap.Difficulty.NORMAL)
	elif hard.has_focus():
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("Add Item") and 
		hard.get_global_rect().has_point(get_global_mouse_position())):
			if not hard.button_pressed and not hard.disabled:
				hard.button_pressed = true
				_last_difficulty_button.button_pressed = false
				_last_difficulty_button = hard
				load_difficulty_save.emit(SongMap.Difficulty.HARD)
			else:
				play_difficulty.emit(SongMap.Difficulty.HARD)
	elif maximus.has_focus():
		if Input.is_action_just_pressed("ui_accept") or (Input.is_action_just_pressed("Add Item") and 
		maximus.get_global_rect().has_point(get_global_mouse_position())):
			if not maximus.button_pressed and not maximus.disabled:
				maximus.button_pressed = true
				_last_difficulty_button.button_pressed = false
				_last_difficulty_button = maximus
				load_difficulty_save.emit(SongMap.Difficulty.MAXIMUS)
			else:
				play_difficulty.emit(SongMap.Difficulty.MAXIMUS)

func has_difficulty() -> bool:
	return not (facil.disabled and normal.disabled and hard.disabled and maximus.disabled)

func get_difficulty_selected() -> SongMap.Difficulty: ## MAKE SURE TO USE HAS_DIFFICULTY() FIRST
	if not facil.disabled:
		return SongMap.Difficulty.FACIL
	if not normal.disabled:
		return SongMap.Difficulty.NORMAL
	elif not hard.disabled:
		return SongMap.Difficulty.HARD
	elif not maximus.disabled:
		return SongMap.Difficulty.MAXIMUS
	else:
		return SongMap.Difficulty.FACIL

func set_difficulty_selected(difficulty : SongMap.Difficulty) -> void:
	match difficulty:
		SongMap.Difficulty.FACIL:
			facil.grab_focus()
		SongMap.Difficulty.NORMAL:
			normal.grab_focus()
		SongMap.Difficulty.HARD:
			hard.grab_focus()
		SongMap.Difficulty.MAXIMUS:
			maximus.grab_focus()

func get_difficulty_button(difficulty : SongMap.Difficulty) -> Button:
	match difficulty:
		SongMap.Difficulty.NORMAL:
			return normal
		SongMap.Difficulty.HARD:
			return hard
		SongMap.Difficulty.MAXIMUS:
			return maximus
	return facil

func _on_facil_focus_entered() -> void:
	if not facil.disabled:
		load_difficulty_save.emit(SongMap.Difficulty.FACIL)
		if not facil.button_pressed:
			facil.button_pressed = not (Input.is_action_just_pressed("Add Item") or (Input.is_action_just_pressed("ui_accept") and
			facil.get_global_rect().has_point(get_global_mouse_position()))) ## MANO...
			_last_difficulty_button.button_pressed = false
			_last_difficulty_button = facil

func _on_normal_focus_entered() -> void:
	if not normal.disabled:
		load_difficulty_save.emit(SongMap.Difficulty.NORMAL)
		if not normal.button_pressed:
			normal.button_pressed = not (Input.is_action_just_pressed("Add Item") or (Input.is_action_just_pressed("ui_accept") and
			normal.get_global_rect().has_point(get_global_mouse_position()))) ## MANO...
			_last_difficulty_button.button_pressed = false
			_last_difficulty_button = normal

func _on_hard_focus_entered() -> void:
	if not hard.disabled:
		load_difficulty_save.emit(SongMap.Difficulty.HARD)
		if not hard.button_pressed:
			hard.button_pressed = not (Input.is_action_just_pressed("Add Item") or (Input.is_action_just_pressed("ui_accept") and
			hard.get_global_rect().has_point(get_global_mouse_position()))) ## MANO...
			_last_difficulty_button.button_pressed = false
			_last_difficulty_button = hard

func _on_maximus_focus_entered() -> void:
	if not maximus.disabled:
		load_difficulty_save.emit(SongMap.Difficulty.MAXIMUS)
		if not maximus.button_pressed:
			maximus.button_pressed = not (Input.is_action_just_pressed("Add Item") or (Input.is_action_just_pressed("ui_accept") and
			maximus.get_global_rect().has_point(get_global_mouse_position()))) ## MANO...
			_last_difficulty_button.button_pressed = false
			_last_difficulty_button = maximus
