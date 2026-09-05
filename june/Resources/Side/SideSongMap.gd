extends Resource

class_name SideSongMap

enum Difficulty {EASY, MEDIUM, HARD, MAXIMUS}
enum Player {ONE, TWO}

@export var targets : Array[TargetResource] = []

@export var difficulty : int = 0
@export var player : int = 0
@export var stars : int = 1
