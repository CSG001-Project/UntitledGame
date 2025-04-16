extends BaseWeapon
class_name Beam

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var sprite2 = $Sprite2D2
@onready var sprite3 = $Sprite2D3
@onready var sprite4 = $Sprite2D4
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
	for raycast in raycasts:
		raycast.force_raycast_update()
		
		# Check if the weapon hit something
		if raycast.is_colliding():
			var target = raycast.get_collider()
			
			# If it is an enemy, deal damage
			if target.is_in_group("enemy"):
				target.get_parent().damage(damage, 0);
