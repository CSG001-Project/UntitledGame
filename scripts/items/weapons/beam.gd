extends RayCast2D

@onready var sprite = $Sprite2D
@onready var timer = $Timer

@export var damage: int = 1

func attack() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var angle = snappedf((global_position - mouse_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
	# Set the rotation of the weapon to the mouse
	rotation = angle
	
	# Check if the weapon hit something
	if is_colliding():
		var target = get_collider()
		
		# If it is an enemy, deal damage
		if target.is_in_group("enemy"):
			target.health.health -= damage
	
	# Flash the beam texture
	sprite.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false
