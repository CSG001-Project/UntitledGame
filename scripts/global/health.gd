class_name Health
extends Node

signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted()

@export var max_health: int = 5 : set = set_max_health, get = get_max_health

@onready var health: int = max_health: set = set_health, get = get_health

func set_max_health(value: int):
	var clamped_value = 1 if value <= 0 else value
	
	if clamped_value != max_health:
		var diffrence = clamped_value - max_health
		max_health = value
		max_health_changed.emit(diffrence)
		
		if health > max_health:
			health = max_health

func get_max_health() -> int:
	return max_health

func set_health(value: int):
	if value < health:
		return
	
	var clamped_value = clampi(value, 0, max_health)
	
	if clamped_value != health:
		var diffrence = clamped_value - health
		health_changed.emit(diffrence)
		
		if health == 0:
			health_depleted.emit() 

func get_health():
	return health
