extends Node2D
class_name BaseWeapon

@export var weapon_range: int = 1
@export var damage: int = 1

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D

func attack_ranged():
	var mouse_position: Vector2 = get_global_mouse_position()
	mouse_position.x = snappedi(mouse_position.x, 32)
	mouse_position.y = snappedi(mouse_position.y, 32)
	global_rotation = (mouse_position - global_position).angle()
	
	#temporary
	sprite.visible = true
	print("Visible")
	while not (approx_equals(global_position.x, mouse_position.x) and approx_equals(global_position.y, mouse_position.y)):
		print("Entered")
		position = position.move_toward(mouse_position, 1)
		raycast.force_raycast_update()
		
		# Check if the weapon hit something
		if raycast.is_colliding():
			print("Colided")
			var target = raycast.get_collider()
			
			# If it is an enemy, deal damage
			if target.is_in_group("enemy"):
				target.get_parent().damage(damage, 0);
				break
	sprite.visible = false

#godot is_approx_equals doesnt work for me for some reason((
func approx_equals(var1, var2) -> bool:
	if var1 < (var2 + 0.5) and var1 > (var2 - 0.5):
		return true
	return false

func attack_melee():
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
	# Set the rotation of the weapon to the mouse
	rotation = angle
	raycast.force_raycast_update()
	
	# Check if the weapon hit something
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		# If it is an enemy, deal damage
		if target.is_in_group("enemy"):
			target.get_parent().damage(damage, 0);
	
	# Flash the beam texture
	sprite.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false
