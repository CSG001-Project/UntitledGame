extends ProgressBar
@onready var health_label = $HealthLabel


func set_health_bar(current: int, max_health: int) -> void:
	await get_tree().process_frame
	self.max_value = max_health
	self.value = current
	health_label.text = "Health: %d/%d" % [current, max_health]
