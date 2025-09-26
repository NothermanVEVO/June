extends Control

class_name GameSettingsScreen

enum GearPositions {CENTER, LEFT, RIGHT}

@onready var _velocity_text : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/VelocityText
@onready var _velocity_slider : HSlider = $PanelContainer/MarginContainer/VBoxContainer/VelocitySlider

@onready var _gear_transparency_text : RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/GearTransparencyText
@onready var _gear_transparency_slider : HSlider = $PanelContainer/MarginContainer/VBoxContainer/GearTransparencySlider

@onready var _gear_position_option : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/GearPositionOption

func _ready() -> void:
	Song.finished.connect(_on_song_finished)
	
	_velocity_slider.grab_focus()
	var dict := Global.get_settings_dictionary()
	
	_velocity_text.text = "Velocidade: " + str(dict["game_speed"])
	_velocity_slider.value = dict["game_speed"]
	
	_gear_transparency_text.text = "Transparência do fundo da Gear:" + str(int(dict["game_gear_transparency"] * 100)) + "%"
	_gear_transparency_slider.value = dict["game_gear_transparency"]
	
	_gear_position_option.select(dict["game_gear_position"])

func _on_song_finished() -> void:
	Song.play()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		_on_return_pressed()

func _on_velocity_slider_value_changed(value: float) -> void:
	var dict := Global.get_settings_dictionary()
	_velocity_text.text = "Velocidade: " + str(value)
	dict["game_speed"] = value
	Global.save_settings(dict)

func _on_gear_transparency_slider_value_changed(value: float) -> void:
	var dict := Global.get_settings_dictionary()
	_gear_transparency_text.text = "Transparência do fundo da Gear:" + str(int(value * 100)) + "%"
	dict["game_gear_transparency"] = value
	Global.save_settings(dict)

func _on_gear_position_option_item_selected(index: int) -> void:
	var dict := Global.get_settings_dictionary()
	dict["game_gear_position"] = index
	Global.save_settings(dict)

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global.SETTING_SCREEN_SCENE)
