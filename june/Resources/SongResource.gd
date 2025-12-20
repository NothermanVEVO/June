extends Resource

class_name SongResource

var ID : String
var name : String
var author : String
var BPM : int
var track : String
var creator : String
var song : String
var image : String
var video : String
var icon : String
var song_maps : Array[SongMap]

var song_time_sample : String
var video_time_sample : String

@warning_ignore("shadowed_variable")
func _init(name : String, author : String, BPM : int, track : String, creator : String, song : String, image : String, video : String, 
	icon : String, song_maps : Array[SongMap], song_time_sample : String, video_time_sample : String) -> void:
	
	self.ID = Global.get_UUID()
	self.name = name
	self.author = author
	self.BPM = BPM
	self.track = track
	self.creator = creator
	self.song = song
	self.image = image
	self.video = video
	self.icon = icon
	self.song_maps = song_maps
	self.song_time_sample = song_time_sample
	self.video_time_sample = video_time_sample

func get_dictionary() -> Dictionary:
	var dictionary := {"ID": ID, "name": name, "author": author, "BPM": BPM, "track": track, "creator": creator, "song": song, "image": image, 
		"video": video, "icon": icon, "song_maps": [], "song_time_sample": song_time_sample, "video_time_sample": video_time_sample}
	
	for song_map in song_maps:
		dictionary["song_maps"].append(song_map.get_dictionary())
	
	return dictionary

static func dictionary_to_resource(dictionary : Dictionary) -> SongResource:
	@warning_ignore("shadowed_variable")
	var song_maps : Array[SongMap] = []
	for dict in dictionary["song_maps"]:
		song_maps.append(SongMap.dictionary_to_resource(dict))
	
	var song_resource := SongResource.new(dictionary["name"], dictionary["author"], dictionary["BPM"], dictionary["track"], dictionary["creator"], dictionary["song"], 
		dictionary["image"], dictionary["video"], dictionary["icon"], song_maps, dictionary["song_time_sample"], dictionary["video_time_sample"])
	
	song_resource.ID = dictionary["ID"]
	
	return song_resource

static func validate_dictionary(dictionary : Dictionary) -> String:
	if not dictionary.has("ID") or typeof(dictionary["ID"]) != TYPE_STRING:
		return "\"ID\" not found or wrong format in SongResource"
	if not dictionary.has("name") or typeof(dictionary["name"]) != TYPE_STRING:
		return "\"name\" not found or wrong format in SongResource"
	if not dictionary.has("author") or typeof(dictionary["author"]) != TYPE_STRING:
		return "\"author\" not found or wrong format in SongResource"
	if not dictionary.has("BPM") or typeof(dictionary["BPM"]) != TYPE_FLOAT:
		return "\"BPM\" not found or wrong format in SongResource"
	if not dictionary.has("track") or typeof(dictionary["track"]) != TYPE_STRING:
		return "\"track\" not found or wrong format in SongResource"
	if not dictionary.has("creator") or typeof(dictionary["creator"]) != TYPE_STRING:
		return "\"creator\" not found or wrong format in SongResource"
	if not dictionary.has("song") or typeof(dictionary["song"]) != TYPE_STRING:
		return "\"song\" not found or wrong format in SongResource"
	if not dictionary.has("image") or typeof(dictionary["image"]) != TYPE_STRING:
		return "\"image\" not found or wrong format in SongResource"
	if not dictionary.has("video") or typeof(dictionary["video"]) != TYPE_STRING:
		return "\"video\" not found or wrong format in SongResource"
	if not dictionary.has("icon") or typeof(dictionary["icon"]) != TYPE_STRING:
		return "\"icon\" not found or wrong format in SongResource"
	if not dictionary.has("song_maps") or typeof(dictionary["song_maps"]) != TYPE_ARRAY:
		return "\"song_maps\" not found or wrong format in SongResource"
	for dict in dictionary["song_maps"]:
		var validate_wrong := SongMap.validate_dictionary(dict)
		if validate_wrong:
			return validate_wrong
	if not dictionary.has("song_time_sample") or typeof(dictionary["song_time_sample"]) != TYPE_STRING:
		return "\"song_time_sample\" not found or wrong format in SongResource"
	if not dictionary.has("video_time_sample") or typeof(dictionary["video_time_sample"]) != TYPE_STRING:
		return "\"video_time_sample\" not found or wrong format in SongResource"
	return ""
