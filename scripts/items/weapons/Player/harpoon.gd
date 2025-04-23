extends BaseWeapon
class_name Harpoon

@onready var timer = $Timer
@onready var sprite = $Sprite2D
@onready var raycast = $RayCast2D
@onready var sound = $AudioStreamPlayer
@onready var hit_animation = $AnimatedSprite2D

func _process(delta: float) -> void:
	var speed: float = 100
	if is_ranged_attacking:
		global_position += velocity * speed * delta
		if (MishaMath.approx_equals(global_position.x, target.x, HALF_TILE) and MishaMath.approx_equals(global_position.y, target.y, HALF_TILE)):
			hit()
			is_ranged_attacking = false
			global_position = player_pos
			sprite.visible = false

func attack_ranged():
	player_pos = global_position
	target = get_global_mouse_position()
	target.x = MishaMath.snapperi(target.x, TILE_SIZE) + HALF_TILE
	target.y = MishaMath.snapperi(target.y, TILE_SIZE) + HALF_TILE
	global_rotation = (global_position - target).angle() - PI/2 #why do I need to do this? sb explain, I have no clue why I need to substract pi/2
	sound.play()
	#temporary
	sprite.visible = true
	is_ranged_attacking = true
	velocity = (target - global_position).normalized()
	while is_ranged_attacking:
		timer.start()
		await timer.timeout

func hit() -> void:
	raycast.force_raycast_update()
	
	# Check if the weapon hit something
	if raycast.is_colliding():
		var target = raycast.get_collider()
		
		# If it is an enemy, deal damage
		if target.is_in_group("enemy"):
			target.get_parent().damage(damage, 0);
