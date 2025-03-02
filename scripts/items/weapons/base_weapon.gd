extends Node2D
class_name BaseWeapon

@export var weapon_range: int = 1
@export var damage: int = 1

@onready var has_hit: bool = false
@onready var area = $Area2D

func _process(_delta: float) -> void:
	var colliders = area.get_overlapping_bodies()
	if not colliders.is_empty():
		for collider in colliders:
			if collider.is_in_group("enemy") and !has_hit:
				collider.damage(damage, 0)
				has_hit = true
