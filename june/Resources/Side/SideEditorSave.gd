extends Resource

class_name SideEditorSave

## Details
@export var song_name : String = ""
@export var song_author : String = ""
@export var collection : String = ""
@export var map_creator : String = ""

## Music
@export var song_path : String = ""
@export var song_show_time : float = 0.0
@export var song_offset : float = 0.0
@export var BPM : int = 0

## Image
@export var banner_path : String = ""
@export var icon_path : String = ""

@export var song_maps : Array[SideSongMap] = []
