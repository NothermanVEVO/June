extends Tap

class_name RealClone

var fake_clones : Array[FakeClone] = []

func _init(start_time : float, path_type : Path.Types) -> void:
	super._init(start_time, path_type)
	texture = SideEditorTexture.CLONE_FINAL_TEXTURE

func add_new_fake_clone(fake_clone : FakeClone) -> void:
	var path_type := get_path_type()
	set_path_type(Path.reverse_path_type(path_type))
	
	fake_clone.real_clone = self
	fake_clone.set_path_type(path_type)
	fake_clone.set_start_time(get_start_time())
	
	set_start_time(SideGameEditor.get_next_grid_time_pos(get_start_time()))
	
	fake_clones.append(fake_clone)
	fake_clones.sort_custom(_sort_by_time)

func _sort_by_time(a: FakeClone, b: FakeClone) -> bool:
	return a.get_start_time() < b.get_start_time()
