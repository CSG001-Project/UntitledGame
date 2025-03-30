extends BaseWeapon
class_name Beam

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D
@onready var sprite2 = $Sprite2D2
@onready var raycast2 = $RayCast2D2
@onready var sprite3 = $Sprite2D3
@onready var raycast3 = $RayCast2D3
@onready var sprite4 = $Sprite2D4
@onready var raycast4 = $RayCast2D4
@onready var raycast5 = $RayCast2D5

func attack_ranged():
	pass

func _ready() -> void:
	weapon_range = 0
	damage = 1

func _process(delta: float) -> void:
	weapon_range = 0
	damage = 1
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



func attack_melee():
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
	# Set the rotation of the weapon to the mouse
	rotation = angle
	raycast.force_raycast_update()
	raycast2.force_raycast_update()
	raycast3.force_raycast_update()
	raycast4.force_raycast_update()
	raycast5.force_raycast_update()
	
	# Check if the weapon hit something
	hit()
	
	# Flash the beam texture
	sprite.visible = true
	sprite2.visible = true
	sprite3.visible = true
	sprite4.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false
	sprite2.visible = false
	sprite3.visible = false
	sprite4.visible = false

func hit() -> void:
	raycast.force_raycast_update()
	raycast2.force_raycast_update()
	raycast3.force_raycast_update()
	raycast4.force_raycast_update()
	raycast5.force_raycast_update()
	
	# Check if the weapon hit something
	if (raycast.is_colliding() || raycast2.is_colliding() || raycast3.is_colliding() || raycast4.is_colliding() || raycast5.is_colliding()):
		var target = raycast.get_collider()
		var target2 = raycast2.get_collider()
		var target3 = raycast3.get_collider()
		var target4 = raycast4.get_collider()
		var target5 = raycast5.get_collider()
		
		# If it is an enemy, deal damage
		if target:
			if target.is_in_group("enemy"):
				target.get_parent().damage(damage, 0);
		if target2:
			if target2.is_in_group("enemy"):  
				target2.get_parent().damage(damage, 0);
		if target3: 
			if target3.is_in_group("enemy"):
				target3.get_parent().damage(damage, 0);
		if target4:
			if target4.is_in_group("enemy"):
				target4.get_parent().damage(damage, 0);
		if target5:
			if target5.is_in_group("enemy"):
				target5.get_parent().damage(damage, 0);
