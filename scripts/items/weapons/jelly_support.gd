extends BaseWeapon
class_name JellySupport

@onready var sprite = $Sprite2D
@onready var timer = $Timer

func attack_melee():
	sprite.visible = true
	timer.start()
	await timer.timeout
	sprite.visible = false
