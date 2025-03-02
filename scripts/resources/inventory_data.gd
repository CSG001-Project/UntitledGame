extends Resource
class_name InventoryData

@export var inventory: Array[ItemData]

signal inventory_updated

func get_item_data(slot_index: int, clear: bool = false) -> ItemData:
	var item_data = inventory[slot_index]
	
	if item_data:
		if clear:
			inventory[slot_index] = null
		inventory_updated.emit()
		return item_data
	else:
		return null

func set_item_data(selected_item: ItemData, slot_index: int) -> ItemData:
	var item_data = inventory[slot_index]
	
	inventory[slot_index] = selected_item
	inventory_updated.emit()
	
	return item_data

func add_item_data(item: ItemData) -> bool:
	for i in inventory.size():
		if not inventory[i]:
			inventory[i] = item
			inventory_updated.emit()
			return true
	
	return false
