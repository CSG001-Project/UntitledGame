extends MarginContainer

@onready var item_texture: TextureRect = $ItemTexture

signal slot_pressed(slot_index: int, input: bool)

func set_item(item_data: ItemData) -> void:
	item_texture.texture = item_data.item_texture
