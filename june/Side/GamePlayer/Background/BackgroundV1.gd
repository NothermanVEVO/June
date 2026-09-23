extends Node2D

var world_x : float = 0.0
const SPEED : float = 500.0
const WIDTH : float = 2560.0

@onready var back_clouds: Sprite2D = $BackClouds/BackClouds
@onready var back_clouds_2: Sprite2D = $BackClouds/BackClouds2
const scale_back_clouds: float = 0.06

@onready var front_clouds: Sprite2D = $FrontClouds/FrontClouds
@onready var front_clouds_2: Sprite2D = $FrontClouds/FrontClouds2
const scale_front_clouds: float = 0.07

@onready var mega_back_floor: Sprite2D = $MegaBackFloor/MegaBackFloor
@onready var mega_back_floor_2: Sprite2D = $MegaBackFloor/MegaBackFloor2
const scale_mega_back_floor: float = 0.1

@onready var back_floor: Sprite2D = $BackFloor/BackFloor
@onready var back_floor_2: Sprite2D = $BackFloor/BackFloor2
const scale_back_floor: float = 0.3

@onready var front_floor: Sprite2D = $FrontFloor/FrontFloor
@onready var front_floor_2: Sprite2D = $FrontFloor/FrontFloor2
const scale_front_floor: float = 0.5


func _process(delta: float) -> void:
	world_x += SPEED * delta
	
	move_layer(back_clouds, back_clouds_2, world_x * scale_back_clouds)
	move_layer(front_clouds, front_clouds_2, world_x * scale_front_clouds)
	move_layer(mega_back_floor, mega_back_floor_2, world_x * scale_mega_back_floor)
	move_layer(back_floor, back_floor_2, world_x * scale_back_floor)
	move_layer(front_floor, front_floor_2, world_x * scale_front_floor)


func move_layer(sprite_a: Sprite2D, sprite_b: Sprite2D, offset: float) -> void:
	sprite_a.position.x = (WIDTH / 2) - fmod(offset, WIDTH) - (WIDTH / 2)
	sprite_b.position.x = sprite_a.position.x + WIDTH
