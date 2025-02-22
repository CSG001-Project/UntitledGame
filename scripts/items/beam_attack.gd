extends Node

@onready var ray = $RayCast2D
var has_hit: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	has_hit = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_hit:
		var target = ray.get_collider()
		if not target == null:
			target.health.set_health(target.health.get_health() - 1)
			has_hit = true
