extends Panel
class_name InventorySlot

@onready var texture_rect: TextureRect = $TextureRect

var current_item: Item = null

func set_item(item: Item) -> void:
	current_item = item
	
	if item == null:
		texture_rect.texture = null
	else:
		texture_rect.texture = item.icon
