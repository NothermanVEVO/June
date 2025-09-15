extends Node

func load_music_stream(path : String):
	var stream
	if path.get_extension() == "mp3":
		stream = AudioStreamMP3.load_from_file(path)
		return stream
	elif path.get_extension() == "wav":
		stream = AudioStreamWAV.load_from_file(path)
		return stream
	elif path.get_extension() == "ogg":
		stream = AudioStreamOggVorbis.load_from_file(path)
		return stream
	return null

func load_image(path : String):
	var image := Image.new()
	var error = image.load(path)
	
	if error != OK:
		return null
	else:
		var image_texture = ImageTexture.new()
		image_texture.set_image(image)
		return image_texture

func load_video_stream(path : String):
	var stream = VideoStreamTheora.new()
	stream.file = path
	
	return stream
