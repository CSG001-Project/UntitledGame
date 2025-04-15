extends BaseWeapon
class_name JellySupport

var is_used: bool = false

@onready var area = $Area2D

func _on_jelly_caboom_attack() -> void:
	if is_used:
		print("Entered")
		var player = get_parent().get_parent().get_parent().get_node("Player")
		if player.global_position == global_position:
			player.health.health -= 1
