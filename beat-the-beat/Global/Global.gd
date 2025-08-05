extends Node

func get_percentage_between(start: float, end: float, value: float) -> float:
	if end == start:
		return 0.0
	return (value - start) / (end - start)
