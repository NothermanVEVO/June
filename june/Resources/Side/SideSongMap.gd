extends Resource

class_name SideSongMap

enum Difficulty {EASY, MEDIUM, HARD, MAXIMUS}
enum Player {ONE, TWO}

@export var air_path : Array[TargetResource] = []
@export var ground_path : Array[TargetResource] = []

@export var difficulty : int = 0
@export var player : int = 0
