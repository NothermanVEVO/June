extends Resource

class_name TargetResource

@export var start_time : float

@export var path_type : int

enum Targets {LIGHT_TAP, MEDIUM_TAP, HEAVY, TWIN, SHIELD, FORTIFIED, REAL_CLONE, FAKE_CLONE, HAMMER, HOLD, TRAP, AXE, NOTE_1, NOTE_2, HEART, CHILD}

@warning_ignore("shadowed_variable")
func _init(start_time : float = 0.0, path_type : int = 0) -> void:
	self.start_time = start_time
	self.path_type = path_type

static func target_to_resource(target : Target) -> TargetResource:
	if target is LightTap:
		return LightTapResource.new(target.get_start_time(), target.get_path_type(), target.get_variant())
	elif target is MediumTap:
		return MediumTapResource.new(target.get_start_time(), target.get_path_type(), target.get_variant())
	elif target is Spam:
		return SpamResource.new(target.get_start_time(), target.get_end_time(), target.get_path_type())
	elif target is TwinTap:
		return TwinTapResource.new(target.get_start_time(), target.get_path_type())
	elif target is TwoTimesDelay:
		return TwoTimesDelayResource.new(target.get_start_time(), target.get_path_type(), target.get_first_time_delay(), target.get_second_time_delay())
	elif target is OneTimeDelay:
		return OneTimeDelayResource.new(target.get_start_time(), target.get_path_type(), target.get_first_time_delay())
	elif target is TwoTimesDelayEditor:
		return TwoTimesDelayResource.new(target.get_start_time(), target.get_path_type(), target.get_first_time_delay(), target.get_second_time_delay())
	elif target is OneTimeDelayEditor:
		return OneTimeDelayResource.new(target.get_start_time(), target.get_path_type(), target.get_first_time_delay())
	elif target is RealClone:
		var real_clone := RealCloneResource.new(target.get_start_time(), target.get_path_type(), [])
		for fake_clone in target.fake_clones:
			real_clone.fake_clones.append(FakeCloneResource.new(fake_clone.get_start_time(), fake_clone.get_path_type()))
		return real_clone
	elif target is FakeClone:
		return null
	elif target is HammerTap:
		return HammerTapResource.new(target.get_start_time(), target.get_path_type())
	elif target is HoldManual:
		return HoldResource.new(target.get_start_time(), target.get_end_time(), target.get_path_type())
	elif target is Trap:
		return TrapResource.new(target.get_start_time(), target.get_path_type())
	elif target is AxeTrap:
		return AxeTrapResource.new(target.get_start_time(), target.get_path_type())
	elif target is MusicalNote:
		return MusicalNoteResource.new(target.get_start_time(), target.get_path_type(), target.get_variant())
	elif target is Heart:
		return HeartResource.new(target.get_start_time(), target.get_path_type())
		
	return null

static func resource_to_target(target_resource : TargetResource) -> Target:
	if target_resource is LightTapResource:
		return LightTap.new(target_resource.start_time, target_resource.path_type, target_resource.variant)
	elif target_resource is MediumTapResource:
		return MediumTap.new(target_resource.start_time, target_resource.path_type, target_resource.get_variant())
	elif target_resource is SpamResource:
		return Spam.new(target_resource.start_time, target_resource.end_time, target_resource.path_type)
	elif target_resource is TwinTapResource:
		return TwinTap.new(target_resource.start_time, target_resource.path_type)
	elif target_resource is TwoTimesDelayResource:
		return TwoTimesDelay.new(target_resource.start_time, target_resource.path_type, target_resource.first_time_delay, target_resource.second_time_delay)
	elif target_resource is OneTimeDelayResource:
		return OneTimeDelay.new(target_resource.start_time, target_resource.path_type, target_resource.first_time_delay)
	elif target_resource is RealCloneResource:
		var real_clone := RealClone.new(target_resource.start_time, target_resource.path_type)
		for fake_clone_resource in target_resource.fake_clones:
			real_clone.add_new_fake_clone(FakeClone.new(fake_clone_resource.start_time, fake_clone_resource.path_type))
		return real_clone
	elif target_resource is FakeCloneResource:
		return null
	elif target_resource is HammerTapResource:
		return HammerTap.new(target_resource.start_time, target_resource.path_type)
	elif target_resource is HoldResource:
		return HoldManual.new(target_resource.start_time, target_resource.end_time, target_resource.path_type)
	elif target_resource is TrapResource:
		return Trap.new(target_resource.start_time, target_resource.path_type)
	elif target_resource is AxeTrapResource:
		return AxeTrap.new(target_resource.start_time, target_resource.path_type)
	elif target_resource is MusicalNoteResource:
		return MusicalNote.new(target_resource.start_time, target_resource.path_type, target_resource.get_variant())
	elif target_resource is HeartResource:
		return Heart.new(target_resource.start_time, target_resource.path_type)
	
	return null
