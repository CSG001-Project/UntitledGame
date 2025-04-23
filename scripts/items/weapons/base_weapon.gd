extends Node2D
class_name BaseWeapon

@export var weapon_range: int = 1
@export var damage: int = 1

var is_ranged_attacking: bool = false
var player_pos: Vector2
var velocity: Vector2
var target: Vector2

const TILE_SIZE: int = 32
const HALF_TILE: int = 16

func attack_ranged():
	pass

func attack_melee():
	pass
