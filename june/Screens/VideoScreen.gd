extends Control

class_name VideoScreen

enum Modes {WINDOW, WINDOW_FULLSCREEN, FULLSCREEN}

enum Vsync {ACTIVATED, DESACTIVATED}

enum MSAA {DISABLED, TWO_X, FOUR_X, EIGHT_X}

static var _mode : Modes

static var _vsync : Vsync

static var _msaa : MSAA

@onready var mode_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/Mode/ModeOptionButton
@onready var vsync_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/Vsync/VsyncOptionButton
@onready var msaa_option_button : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/MSAA/MSAAOptionButton
@onready var video_check_box : CheckBox = $PanelContainer/MarginContainer/VBoxContainer/Video
@onready var particles_check_box : CheckBox = $PanelContainer/MarginContainer/VBoxContainer/Particles

func _ready() -> void:
	mode_option_button.grab_focus()
	
	var dict := Global.get_settings_dictionary()
	mode_option_button.select(dict["video_mode"])
	vsync_option_button.select(dict["video_vsync"])
	msaa_option_button.select(dict["video_msaa"])
	video_check_box.button_pressed = dict["video"]
	particles_check_box.button_pressed = dict["particles"]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		_on_return_pressed()

func set_mode(mode : Modes) -> void:
	_mode = mode
	var dict := Global.get_settings_dictionary()
	dict["video_mode"] = mode
	Global.save_settings(dict)

func set_vsync(vsync : Vsync) -> void:
	_vsync = vsync
	var dict := Global.get_settings_dictionary()
	dict["video_vsync"] = vsync
	Global.save_settings(dict)

func set_msaa(msaa : MSAA) -> void:
	_msaa = msaa
	var dict := Global.get_settings_dictionary()
	dict["video_msaa"] = msaa
	Global.save_settings(dict)

func _on_mode_option_button_item_selected(index: int) -> void:
	set_mode(index)

func _on_vsync_option_button_item_selected(index: int) -> void:
	set_vsync(index)

func _on_msaa_option_button_item_selected(index: int) -> void:
	set_msaa(index)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global._SETTING_SCREEN_SCENE)

func _on_video_toggled(toggled_on: bool) -> void:
	var dict := Global.get_settings_dictionary()
	if dict["video"] != toggled_on:
		dict["video"] = toggled_on
		Global.save_settings(dict)

func _on_particles_toggled(toggled_on: bool) -> void:
	var dict := Global.get_settings_dictionary()
	if dict["particles"] != toggled_on:
		dict["particles"] = toggled_on
		Global.save_settings(dict)
