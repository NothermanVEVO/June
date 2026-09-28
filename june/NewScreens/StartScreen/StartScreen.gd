extends Control

var _settings_scene : PackedScene = load("res://NewScreens/Settings/Settings.tscn")

@onready var background: Control = $Background
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var press_to_play: Control = $PressToPlay

static var _first_time = true

var _choose_mode_scene := load("res://NewScreens/ChooseGame/ChooseMode.tscn")

func _ready() -> void:
	Song.stop()
	
	Global.set_window_title(Global.TitleType.BASE)
	SideEditor.is_on_editor = false
	
	if _first_time:
		return
	
	_change_to_normal_display()

func _change_to_normal_display() -> void:
	$VBoxContainer/MarginContainer/VBoxContainer/PlayButton.grab_focus()
	background.modulate.a = 1.0
	v_box_container.visible = true
	press_to_play.visible = false

func _input(event: InputEvent) -> void:
	if _first_time and event is InputEventMouseButton:
		_first_time = false
		_change_to_normal_display()

func _unhandled_input(_event: InputEvent) -> void:
	if _first_time:
		_first_time = false
		_change_to_normal_display()

func _on_play_button_pressed() -> void:
	#ChooseMode.path_to_go = ChooseMode.Paths.PLAY
	#get_tree().change_scene_to_packed(_choose_mode_scene) ## TODO
	pass # Replace with function body.

func _on_edit_button_pressed() -> void:
	ChooseMode.path_to_go = ChooseMode.Paths.EDITOR
	get_tree().change_scene_to_packed(_choose_mode_scene)

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(_settings_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
