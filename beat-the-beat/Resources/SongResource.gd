extends Resource

class_name SongResource

var ID : String
var name : String
var author : String
var BPM : int
var track : String
var song : String
var image : String
var video : String
var icon : String
var song_maps : Array[SongMap]

var song_time_sample : String
var video_time_sample : String

@warning_ignore("shadowed_variable")
func _init(name : String, author : String, BPM : int, track : String, song : String, image : String, video : String, 
	icon : String, song_maps : Array[SongMap], song_time_sample : String, video_time_sample : String) -> void:
	
	self.ID = Global.get_UUID()
	self.name = name
	self.author = author
	self.BPM = BPM
	self.track = track
	self.song = song
	self.image = image
	self.video = video
	self.icon = icon
	self.song_maps = song_maps
	self.song_time_sample = song_time_sample
	self.video_time_sample = video_time_sample

func get_dictionary() -> Dictionary:
	var dictionary := {"id": ID, "name": name, "author": author, "BPM": BPM, "track": track, "song": song, "image": image, 
		"video": video, "icon": icon, "song_maps": []}
	
	for song_map in song_maps:
		dictionary["song_maps"].append(song_map.get_dictionary())
	
	return dictionary
