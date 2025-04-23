extends BaseWeapon
class_name Beam

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycaster = $RayCaster
@onready var sound = $AudioStreamPlayer
@onready var raycasts = raycaster.get_children()

func attack_melee():
	sound.play()
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
	# Set the rotation of the weapon to the mouse
	rotation = angle
	
	# Check if the weapon hit something
	hit()
	
	# Flash the beam texture
	sprite.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false

func hit() -> void:
	for raycast in raycasts:
		raycast.force_raycast_update()
		
		# Check if the weapon hit something
		if raycast.is_colliding():
			var collision = raycast.get_collider()
			
			# If it is an enemy, deal damage
			if collision.is_in_group("enemy"):
				collision.get_parent().damage(damage, 0);
