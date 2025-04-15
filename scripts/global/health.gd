extends Node
class_name Health

signal max_health_changed(difference: int)
signal health_changed(difference: int)
signal health_depleted

@export var max_health: int = 5: set = set_max_health
#SHAY HI
var health: int = max_health: set = set_health

func set_max_health(value: int):
	# see if health is not stupid 
	var clamped_value = 1 if value <= 0 else value
	
	# check if health was changed 
	if clamped_value != max_health:
		var difference = clamped_value - max_health
		
		max_health = clamped_value
		max_health_changed.emit(difference)
		# In case your current health is higher than your max health
		if health > max_health:
			health = max_health

func set_health(value: int):
	# see if health is not stupid 
	var clamped_value = clampi(value, 0, max_health)
	
	# check if health was changed 
	if clamped_value != health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		# In case DIE
		if health <= 0:
			health_depleted.emit()
