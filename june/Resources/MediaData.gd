extends Resource

class_name MediaData

@export var icon : Texture2D
@export var image : Texture2D
@export var song : AudioStream
@export var video : VideoStream

@warning_ignore("shadowed_variable")
func _init(icon : Texture2D = null, image : Texture2D = null, song : AudioStream = null, video : VideoStream = null) -> void:
	self.icon = icon
	self.image = image
	self.song = song
	self.video = video
