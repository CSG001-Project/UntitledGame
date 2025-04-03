extends ProgressBar
@onready var health_label = $HealthLabel


func set_health_bar(current: int, max: int) -> void:
	await get_tree().process_frame
	self.max_value = max
	self.value = current
	health_label.text = "Health: %d/%d" % [max, current]
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
