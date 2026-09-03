extends Resource

class_name TargetResource

@export var start_time : float

@export var path_type : int

@export var target_type : int

enum Targets {LIGHT_TAP, MEDIUM_TAP, HEAVY, TWIN, SHIELD, FORTIFIED, REAL_CLONE, FAKE_CLONE, HAMMER, HOLD, TRAP, AXE, NOTE_1, NOTE_2, HEART, CHILD}

@warning_ignore("shadowed_variable")
func _init(start_time : float = 0.0, path_type : int = 0, target_type : int = 0) -> void:
	self.start_time = start_time
	self.path_type = path_type
	self.target_type = target_type

static func get_target_type(target : Target) -> int:
	if target is LightTap:
		return Targets.LIGHT_TAP
	elif target is MediumTap:
		return Targets.MEDIUM_TAP
	elif target is Spam:
		return Targets.HEAVY
	elif target is TwinTap:
		return Targets.TWIN
	elif target is TwoTimesDelay:
		return Targets.FORTIFIED
	elif target is OneTimeDelay:
		return Targets.SHIELD
	elif target is TwoTimesDelayEditor:
		return Targets.FORTIFIED
	elif target is OneTimeDelayEditor:
		return Targets.SHIELD
	elif target is RealClone:
		return Targets.REAL_CLONE
	elif target is FakeClone:
		return Targets.FAKE_CLONE
	elif target is HammerTap:
		return Targets.HAMMER
	elif target is HoldManual:
		return Targets.HOLD
	elif target is Trap:
		return Targets.TRAP
	elif target is AxeTrap:
		return Targets.AXE
	elif target is MusicalNote:
		if target.get_variant() == MusicalNote.Variants.ONE:
			return Targets.NOTE_1
		else:
			return Targets.NOTE_2
	elif target is Heart:
		return Targets.HEART
	
	return -1

static func target_to_resource(target : Target) -> TargetResource:
	@warning_ignore("shadowed_variable")
	var target_type : int = get_target_type(target)
	
	match target_type:
		Targets.LIGHT_TAP, Targets.MEDIUM_TAP, Targets.TWIN, Targets.HAMMER, Targets.TRAP, Targets.AXE, Targets.NOTE_1, Targets.NOTE_2, Targets.HEART:
			return TargetResource.new(target.get_start_time(), target.get_path_type(), target_type)
		Targets.HEAVY, Targets.HOLD:
			return HoldTargetResource.new(target.get_start_time(), target.get_end_time(), target.get_path_type(), target_type)
		Targets.SHIELD:
			var first := ChildTargetResource.new(target.get_first_time_delay(), target.get_path_type(), Targets.CHILD, 0)
			return ParentTargetResource.new(target.get_start_time(), target.get_path_type(), target_type, [first])
		Targets.FORTIFIED:
			var first := ChildTargetResource.new(target.get_first_time_delay(), target.get_path_type(), Targets.CHILD, 0)
			var second := ChildTargetResource.new(target.get_second_time_delay(), target.get_path_type(), Targets.CHILD, 1)
			return ParentTargetResource.new(target.get_start_time(), target.get_path_type(), target_type, [first, second])
		Targets.REAL_CLONE:
			var real_clone := ParentTargetResource.new(target.get_start_time(), target.get_path_type(), target_type, []) 
			var idx : int = 0
			for fake_clone in target.fake_clones:
				real_clone.childs.append(ChildTargetResource.new(fake_clone.get_start_time(), fake_clone.get_path_type(), Targets.CHILD, idx))
				idx += 1
			return real_clone
		
	return null

static func resource_to_target(target_resource : TargetResource) -> Target:
	return null
