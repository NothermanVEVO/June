extends FlowContainer

class_name EditorMenuBar

@onready var snap_divisor := $FlowContainer/SnapDivisor

static var _snap_divisor_value : int = 1

enum Divisors{ONE = 1, TWO = 2, FOUR = 4, EIGHT = 8, TWELVE = 12, SIXTEEN = 16}

static func get_snap_divisor_value() -> int:
	return _snap_divisor_value

func _on_speed_value_changed(value: float) -> void:
	Gear.set_speed(value)

func _on_snap_divisor_item_selected(index: int) -> void:
	_snap_divisor_value = Divisors.values()[index]

static func get_divisor() -> float:
	return 60.0 / Song.BPM / _snap_divisor_value
