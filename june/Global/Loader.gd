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
	if not FileAccess.file_exists(path):
		return null
	var image := Image.load_from_file(path)
	
	return ImageTexture.create_from_image(image)

func load_video_stream(path : String):
	var stream = VideoStreamTheora.new()
	stream.file = path
	
	return stream
