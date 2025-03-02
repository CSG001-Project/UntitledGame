extends MarginContainer

@onready var item_texture: TextureRect = $ItemTexture

signal slot_pressed(slot_index: int)

func set_item(item_data: ItemData) -> void:
	item_texture.texture = item_data.item_texture

func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_pressed("interact"):
		slot_pressed.emit(get_index())
