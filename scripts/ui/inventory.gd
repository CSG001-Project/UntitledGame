extends TextureRect

@export var inventory_data: InventoryData
@onready var item_grid: GridContainer = $ItemGrid
@onready var held_item: MarginContainer = $HeldItem

var selected_item: ItemData:
	set(new_value):
		selected_item = new_value
		update_held_item()

const slot = preload("res://scenes/ui/slot.tscn")

func _ready() -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid()

func _process(_delta: float) -> void:
	if held_item.visible:
		held_item.global_position = get_global_mouse_position() - Vector2(16,16)

func populate_item_grid() -> void:
	for i in item_grid.get_children():
		i.queue_free()
	
	for item_data in inventory_data.inventory:
		var slot_instance = slot.instantiate()
		
		item_grid.add_child(slot_instance)
		
		slot_instance.slot_pressed.connect(on_slot_pressed)
		
		if item_data:
			slot_instance.set_item(item_data)

func on_slot_pressed(slot_index: int) -> void:
	if !selected_item:
		selected_item = inventory_data.get_item_data(slot_index, true)
	else:
		selected_item = inventory_data.set_item_data(selected_item, slot_index)

func update_held_item() -> void:
	if selected_item:
		held_item.show()
		held_item.set_item(selected_item)
	else:
		held_item.hide()

func drop_item() -> ItemData:
	var item = selected_item
	
	selected_item = null
	return item
