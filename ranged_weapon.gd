extends Node
class_name Weapon

@export var range: int = 0: set = set_range
@export var is_ranged: bool = true
@export var damage: int = 1

@onready var has_hit: bool = false
@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var colliders = area.get_overlapping_bodies()
	if not colliders.is_empty():
		for collider in colliders:
			if colliders[collider].is_in_group("enemy") and !has_hit:
				colliders[collider].damage(damage, 0)
				has_hit = true

func set_range(value: int):
	if not is_ranged:
		range = 0
	else:
		if value <= 0:
			range = 1
		else:
			range = value
