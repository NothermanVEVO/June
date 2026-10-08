extends Control

class_name Settings

enum GearPositions {CENTER, LEFT, RIGHT}

## AUDIO
@onready var main_volume_text: RichTextLabel = $TabContainerSettings/Audio/VBoxContainer/MarginContainer/VBoxContainer/MainVolume/MainVolumeText
@onready var main_volume_slider: HSlider = $TabContainerSettings/Audio/VBoxContainer/MarginContainer/VBoxContainer/MainVolume/MainVolumeSlider
@onready var sfx_volume_text: RichTextLabel = $TabContainerSettings/Audio/VBoxContainer/MarginContainer/VBoxContainer/SFXVolume/SFXVolumeText
@onready var sfx_volume_slider: HSlider = $TabContainerSettings/Audio/VBoxContainer/MarginContainer/VBoxContainer/SFXVolume/SFXVolumeSlider

## CONTROLS
@onready var _1_4k: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/1_4k"
@onready var _2_4k: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/2_4k"
@onready var _3_4k: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/3_4k"
@onready var _4_4k: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/4_4k"

@onready var _1_air: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/Side Buttons/VBoxContainer/HBoxContainer/1_air"
@onready var _2_air: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/Side Buttons/VBoxContainer/HBoxContainer/2_air"
@onready var _1_ground: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/Side Buttons/VBoxContainer/HBoxContainer/1_ground"
@onready var _2_ground: Button = $"TabContainerSettings/Controles/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/Side Buttons/VBoxContainer/HBoxContainer/2_ground"

var _button_toggled_on : Button

const INVALID_PHYSICAL_KEYCODE : Array[int] = [4194305, 49, 50, 4194336] ## [ESCAPE, 1, 2, F5].

## GAME
@onready var _velocity_text: RichTextLabel = $TabContainerSettings/Jogo/VBoxContainer/VelocityText
@onready var _velocity_slider: HSlider = $TabContainerSettings/Jogo/VBoxContainer/VelocitySlider

@onready var _gear_transparency_text: RichTextLabel = $TabContainerSettings/Jogo/VBoxContainer/GearTransparencyText
@onready var _gear_transparency_slider: HSlider = $TabContainerSettings/Jogo/VBoxContainer/GearTransparencySlider

@onready var _gear_position_option: OptionButton = $TabContainerSettings/Jogo/VBoxContainer/GearPositionOption

## VIDEO
@onready var mode_option_button: OptionButton = $TabContainerSettings/Video/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Mode/ModeOptionButton
@onready var vsync_option_button: OptionButton = $TabContainerSettings/Video/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Vsync/VsyncOptionButton
@onready var video_check_box: CheckBox = $TabContainerSettings/Video/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/VideoCheckBox
@onready var particles_check_box: CheckBox = $TabContainerSettings/Video/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/ParticlesCheckBox
@onready var glow_check_box: CheckBox = $TabContainerSettings/Video/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GlowCheckBox

## OTHERS
enum LastSceneBefore {START, SELECTION}
static var last_scene_before : LastSceneBefore

func _ready() -> void:
	Song.finished.connect(_on_song_finished)
	
	#main_volume_slider.grab_focus() ## TODO
	
	var dict := Global.get_settings_dictionary()
	
	## AUDIO
	main_volume_slider.value = dict["audio_main_volume"]
	_on_main_volume_slider_value_changed(dict["audio_main_volume"])
	
	sfx_volume_slider.value = dict["audio_sfx"]
	_on_sfx_volume_slider_value_changed(dict["audio_sfx"])
	
	## CONTROLS
	# 4 KEYS FALL
	_1_4k.text = char(dict[_1_4k.name])
	_2_4k.text = char(dict[_2_4k.name])
	_3_4k.text = char(dict[_3_4k.name])
	_4_4k.text = char(dict[_4_4k.name])
	
	# SIDE
	_1_air.text = char(dict[_1_air.name])
	_2_air.text = char(dict[_2_air.name])
	_1_ground.text = char(dict[_1_ground.name])
	_2_ground.text = char(dict[_2_ground.name])
	
	## GAME
	_velocity_text.text = "Velocidade: %.1fx" % [dict["game_speed"]]
	_velocity_slider.value = dict["game_speed"]
	
	_gear_transparency_text.text = "Transparência do fundo da Gear: " + str(int(dict["game_gear_transparency"] * 100)) + "%"
	_gear_transparency_slider.value = dict["game_gear_transparency"]
	
	_gear_position_option.select(dict["game_gear_position"])
	
	## VIDEO
	mode_option_button.select(dict["video_mode"])
	vsync_option_button.select(dict["video_vsync"])
	video_check_box.button_pressed = dict["video"]
	particles_check_box.button_pressed = dict["particles"]
	glow_check_box.button_pressed = dict["glow"]

func _unhandled_key_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape") and not _button_toggled_on:
		_on_return_pressed()
	if _button_toggled_on and event is InputEventKey:
		if Input.is_action_just_pressed("ui_accept"):
			return
		if event.physical_keycode in INVALID_PHYSICAL_KEYCODE:
			_button_toggled_on.button_pressed = false
			return
		if event.physical_keycode == 4194309:
			return
		InputMap.erase_action(_button_toggled_on.name)
		InputMap.add_action(_button_toggled_on.name)
		InputMap.action_add_event(_button_toggled_on.name, event)
		var dict := Global.get_settings_dictionary()
		dict[_button_toggled_on.name] = event.physical_keycode
		Global.save_settings(dict)
		_button_toggled_on.button_pressed = false

func _on_song_finished() -> void:
	if is_inside_tree():
		Song.play()

func _on_return_pressed() -> void:
	if last_scene_before == LastSceneBefore.START:
		get_tree().change_scene_to_packed(Global.START_SCREEN_SCENE)
	else: ## SELECTION
		get_tree().change_scene_to_packed(Global.SELECTION_SCREEN_SCENE)

## AUDIO
func _on_main_volume_slider_value_changed(value: float) -> void:
	var volume_percentage = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Song"), linear_to_db(volume_percentage))
	var dict := Global.get_settings_dictionary()
	dict["audio_main_volume"] = volume_percentage
	Global.save_settings(dict)
	main_volume_text.text = "Volume principal: " + ("%0.1f" % (dict["audio_main_volume"] * 100)) + "%"

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	var volume_percentage = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effect"), linear_to_db(volume_percentage))
	var dict := Global.get_settings_dictionary()
	dict["audio_sfx"] = volume_percentage
	Global.save_settings(dict)
	sfx_volume_text.text = "Efeitos sonoros: " + ("%0.1f" % (dict["audio_sfx"] * 100)) + "%"

## CONTROLS
func _handle_binding_event(toggled_on : bool, button_toggled : Button) -> void:
	if toggled_on:
		button_toggled.text = "Press any key..."
		if _button_toggled_on and _button_toggled_on.button_pressed:
			_button_toggled_on.button_pressed = false
		_button_toggled_on = button_toggled
	else:
		var dict := Global.get_settings_dictionary()
		button_toggled.text = char(dict[button_toggled.name])
		_button_toggled_on = null

func _on_1_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _1_4k)

func _on_2_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _2_4k)

func _on_3_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _3_4k)

func _on_4_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _4_4k)

func _on_1_air_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _1_air)

func _on_2_air_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _2_air)

func _on_1_ground_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _1_ground)

func _on_2_ground_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, _2_ground)

## VIDEO
func _on_mode_option_button_item_selected(index: int) -> void:
	var dict := Global.get_settings_dictionary()
	dict["video_mode"] = index
	Global.save_settings(dict)

func _on_vsync_option_button_item_selected(index: int) -> void:
	var dict := Global.get_settings_dictionary()
	dict["video_vsync"] = index
	Global.save_settings(dict)

func _on_video_check_box_toggled(toggled_on: bool) -> void:
	var dict := Global.get_settings_dictionary()
	if dict["video"] != toggled_on:
		dict["video"] = toggled_on
		Global.save_settings(dict)

func _on_particles_check_box_toggled(toggled_on: bool) -> void:
	var dict := Global.get_settings_dictionary()
	if dict["particles"] != toggled_on:
		dict["particles"] = toggled_on
		Global.save_settings(dict)

func _on_glow_check_box_toggled(toggled_on: bool) -> void:
	var dict := Global.get_settings_dictionary()
	if dict["glow"] != toggled_on:
		dict["glow"] = toggled_on
		Global.save_settings(dict)

## GAME
func _on_velocity_slider_value_changed(value: float) -> void:
	var dict := Global.get_settings_dictionary()
	_velocity_text.text = "Velocidade: " + str(value)
	dict["game_speed"] = value
	Global.save_settings(dict)

func _on_gear_transparency_slider_value_changed(value: float) -> void:
	var dict := Global.get_settings_dictionary()
	_gear_transparency_text.text = "Transparência do fundo da Gear: " + str(int(value * 100)) + "%"
	dict["game_gear_transparency"] = value
	Global.save_settings(dict)

func _on_gear_position_option_item_selected(index: int) -> void:
	var dict := Global.get_settings_dictionary()
	dict["game_gear_position"] = index
	Global.save_settings(dict)
