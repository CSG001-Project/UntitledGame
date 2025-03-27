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

func _process(delta: float) -> void:
	var speed = Vector2(10,10)
	if is_ranged_attacking:
		print("Attacking")
		position += velocity * speed * delta
		if (MishaMath.approx_equals(global_position.x, target.x, 16) and MishaMath.approx_equals(global_position.y, target.y, 16)):
			print("Hitting")
			hit()
			is_ranged_attacking = false
			global_position = player_pos
			sprite.visible = false

func attack_ranged():
	print("Tried shooting")
	player_pos = global_position
	target = get_global_mouse_position()
	target.x = snappedi(target.x, 32)
	target.y = snappedi(target.y, 32)
	global_rotation = (target - global_position).angle()
	
	#temporary
	sprite.visible = true
	is_ranged_attacking = true
	velocity = target.normalized()

func attack_melee():
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
	# Set the rotation of the weapon to the mouse
	rotation = angle
	raycast.force_raycast_update()
	
	# Check if the weapon hit something
	hit()
	
	# Flash the beam texture
	sprite.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false

func hit() -> void:
	raycast.force_raycast_update()
	
	# Check if the weapon hit something
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		# If it is an enemy, deal damage
		if target.is_in_group("enemy"):
			target.get_parent().damage(damage, 0);
