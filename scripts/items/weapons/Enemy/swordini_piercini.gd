extends BaseWeapon
class_name SwordiniPiercini

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D
@onready var sound = $AudioStreamPlayer
@onready var hit_animation = $AnimatedSprite2D

func attack_melee():
	sound.play()
	var player = get_parent().get_parent().get_node("Player")
	var angle = snappedf((global_position - player.global_position).angle(), deg_to_rad(90)) - deg_to_rad(90)
	
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
	# Check if the weapon hit something
	raycast.force_raycast_update()
	if raycast.is_colliding():
		hit_animation.play("hit animation")

		
		var target = raycast.get_collider()
		target.get_parent().health.health -= 1
