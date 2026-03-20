extends PanelContainer
class_name InventorySlot

@onready var texture_rect: TextureRect = $TextureRect

@export var current_item: Item = null

func set_item(item: Item) -> void:
	current_item = item
	
	if item == null:
		texture_rect.texture = null
	else:
		texture_rect.texture = item.icon


func _on_mouse_entered() -> void:
	if current_item == null:
		return
	if current_item:
		Popups.ItemPopup(self, current_item)


func _on_mouse_exited() -> void:
	Popups.HideItemPopup()
