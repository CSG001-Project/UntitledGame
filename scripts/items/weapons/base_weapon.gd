extends Node2D
class_name BaseWeapon

@export var weapon_range: int = 1
@export var damage: int = 1

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D

var is_ranged_attacking:bool = false
var player_pos: Vector2
var velocity: Vector2
var target: Vector2

const TILE_SIZE: int = 32
const HALF_TILE: int = 16

func _process(delta: float) -> void:
	pass

func attack_ranged():
	pass

func attack_melee():
	pass

func hit() -> void:
	raycast.force_raycast_update()
	
	# Check if the weapon hit something
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		# If it is an enemy, deal damage
		if target.is_in_group("enemy"):
			target.get_parent().damage(damage, 0);
