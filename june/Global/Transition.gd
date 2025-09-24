extends ColorRect

const DIAMOND_BASED := preload("res://shaders/DiamondBasedTransition.gdshader")

var diamond_pixel_size : float = 25
var tween: Tween

signal transition_finished

func _ready():
	z_index = 100
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	color = Color.BLACK
	
	material = ShaderMaterial.new()
	material.shader = DIAMOND_BASED
	
	visible = false
	## REMOVE THIS
	#material.set_shader_parameter("progress", 1.0)
	#visible = true
	#empty()
	

func _play_transition(from: float, to: float, invert: bool, duration: float):
	visible = true
	material.set_shader_parameter("invert", invert)
	material.set_shader_parameter("diamondPixelSize", diamond_pixel_size)
	material.set_shader_parameter("progress", from)
	
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(material, "shader_parameter/progress", to, duration)
	
	tween.finished.connect(func():
		if to == 0.0:
			visible = false
		emit_signal("transition_finished")
	)

func fill(invert := false, duration := 1.0):
	_play_transition(0.0, 1.0, invert, duration)

func empty(invert := false, duration := 1.0):
	_play_transition(1.0, 0.0, invert, duration)

func transition_to_scene(path: String, invert := false, duration := 1.0):
	# Fecha a tela
	fill(invert, duration)
	await self.transition_finished
	
	# Troca a cena
	get_tree().change_scene_to_file(path)
	
	# Abre a tela
	empty(invert, duration)
	await self.transition_finished
