extends Control

@onready var first_four_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/1_4k"
@onready var second_four_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/2_4k"
@onready var third_four_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/3_4k"
@onready var fourth_four_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/4/4 Buttons/VBoxContainer/HBoxContainer/4_4k"

@onready var first_five_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/5 Buttons/VBoxContainer/HBoxContainer/1_5k"
@onready var second_five_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/5 Buttons/VBoxContainer/HBoxContainer/2_5k"
@onready var third_five_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/5 Buttons/VBoxContainer/HBoxContainer/3_5k"
@onready var fourth_five_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/5 Buttons/VBoxContainer/HBoxContainer/4_5k"
@onready var fifth_five_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/5 Buttons/VBoxContainer/HBoxContainer/5_5k"

@onready var first_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/1_6k"
@onready var second_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/2_6k"
@onready var third_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/3_6k"
@onready var fourth_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/4_6k"
@onready var fifth_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/5_6k"
@onready var sixth_six_keys_button : Button = $"MarginContainer/PanelContainer/VBoxContainer/6/6 Buttons/VBoxContainer/HBoxContainer/6_6k"

var _button_toggled_on : Button

const INVALID_PHYSICAL_KEYCODE : Array[int] = [4194305, 49, 50, 4194336] ## [ESCAPE, 1, 2, F5].

func _ready() -> void:
	first_four_keys_button.grab_focus()
	
	var dict := Global.get_settings_dictionary()
	
	## 4 KEYS
	first_four_keys_button.text = char(dict[first_four_keys_button.name])
	second_four_keys_button.text = char(dict[second_four_keys_button.name])
	third_four_keys_button.text = char(dict[third_four_keys_button.name])
	fourth_four_keys_button.text = char(dict[fourth_four_keys_button.name])
	
	## 5 KEYS
	first_five_keys_button.text = char(dict[first_five_keys_button.name])
	second_five_keys_button.text = char(dict[second_five_keys_button.name])
	third_five_keys_button.text = char(dict[third_five_keys_button.name])
	fourth_five_keys_button.text = char(dict[fourth_five_keys_button.name])
	fifth_five_keys_button.text = char(dict[fifth_five_keys_button.name])
	
	## 6 KEYS
	first_six_keys_button.text = char(dict[first_six_keys_button.name])
	second_six_keys_button.text = char(dict[second_six_keys_button.name])
	third_six_keys_button.text = char(dict[third_six_keys_button.name])
	fourth_six_keys_button.text = char(dict[fourth_six_keys_button.name])
	fifth_six_keys_button.text = char(dict[fifth_six_keys_button.name])
	sixth_six_keys_button.text = char(dict[sixth_six_keys_button.name])

func _on_return_pressed() -> void:
	get_tree().change_scene_to_packed(Global.SETTING_SCREEN_SCENE)

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
		#set_process_unhandled_key_input(false)

func _handle_binding_event(toggled_on : bool, button_toggled : Button) -> void:
	if toggled_on:
		button_toggled.text = "Press any key..."
		if _button_toggled_on and _button_toggled_on.button_pressed:
			_button_toggled_on.button_pressed = false
		_button_toggled_on = button_toggled
		#set_process_unhandled_key_input(true)
	else:
		var dict := Global.get_settings_dictionary()
		button_toggled.text = char(dict[button_toggled.name])
		#_button_toggled_on.release_focus()
		_button_toggled_on = null

## 4 KEYS
func _on_1_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, first_four_keys_button)

func _on_2_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, second_four_keys_button)

func _on_3_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, third_four_keys_button)

func _on_4_4k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, fourth_four_keys_button)

## 5 KEYS
func _on_1_5k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, first_five_keys_button)

func _on_2_5k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, second_five_keys_button)

func _on_3_5k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, third_five_keys_button)

func _on_4_5k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, fourth_five_keys_button)

func _on_5_5k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, fifth_five_keys_button)

## 6 KEYS
func _on_1_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, first_six_keys_button)

func _on_2_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, second_six_keys_button)

func _on_3_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, third_six_keys_button)

func _on_4_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, fourth_six_keys_button)

func _on_5_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, fifth_six_keys_button)

func _on_6_6k_toggled(toggled_on: bool) -> void:
	_handle_binding_event(toggled_on, sixth_six_keys_button)
