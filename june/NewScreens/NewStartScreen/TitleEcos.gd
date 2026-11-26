
extends Control

@export var text : String

@export var speed: float = 80.0
@export var spacing: float = 0.0

@onready var label1: RichTextLabel = $TitleEco
@onready var label2: RichTextLabel = $TitleEco2

var label_width: float = 0.0

func _ready() -> void:
	label1.text = text
	label2.text = text

	await get_tree().process_frame

	label_width = label1.size.x

	label1.position.x = -(label_width / 2) - spacing
	label2.position.x = label1.position.x - label_width - spacing

func _process(delta: float) -> void:
	var movement := speed * delta

	label1.position.x += movement
	label2.position.x += movement

	# Quando o primeiro sair completamente pela direita
	if label1.position.x >= size.x:
		label1.position.x = label2.position.x - label_width - spacing

	# Quando o segundo sair completamente pela direita
	if label2.position.x >= size.x:
		label2.position.x = label1.position.x - label_width - spacing
