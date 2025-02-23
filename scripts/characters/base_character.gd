extends StaticBody2D
class_name BaseCharacter

func _ready() -> void:
	TurnManager.update_sprite.connect(update_sprite)

func update_sprite() -> void:
	assert(false, "Sprite must be updated")
