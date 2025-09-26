extends Control

class_name LoadingScreen

const _PRESS_TO_PLAY_SCREEN_SCENE := preload("res://Screens/PressToPlayScreen.tscn")

var quantity_loaded : int = 0
var quantity_of_loaders : int = 0

const _GEAR_SKIN_SCENE := preload("res://Gear/Skins/JuneSkin.tscn")
var _gear_skin : GearSkin

const _HIT_EFFECT_SCENE := preload("res://Effects/Hit/HitEffect.tscn")
var _hit_effect : HitEffect

const _RESULTS_SCREEN_SCENE := preload("res://Screens/ResultsScreen.tscn")
var _result_screen : ResultsScreen

@onready var _loading_text : RichTextLabel = $MarginContainer/LoadingText

func _ready() -> void:
	_gear_skin = _GEAR_SKIN_SCENE.instantiate()
	add_child(_gear_skin)
	quantity_of_loaders += _gear_skin.load_gear(self)
	
	_hit_effect = _HIT_EFFECT_SCENE.instantiate()
	add_child(_hit_effect)
	quantity_of_loaders += _hit_effect.load_gear(self)
	
	_result_screen = _RESULTS_SCREEN_SCENE.instantiate()
	_result_screen.for_loading = true
	add_child(_result_screen)
	quantity_of_loaders += _result_screen.load_gear(self)
	
	_loading_text.text = "Carregando... (0/" + str(quantity_of_loaders) + ")"
	
	#print(quantity_of_loaders)

func loaded(_anim : String = "") -> void:
	#print(_anim)
	quantity_loaded += 1
	_loading_text.text = "Carregando... (" + str(quantity_loaded) + "/" + str(quantity_of_loaders) + ")"
	if quantity_loaded >= quantity_of_loaders:
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(_PRESS_TO_PLAY_SCREEN_SCENE)
