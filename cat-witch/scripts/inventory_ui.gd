extends CanvasLayer
class_name InventoryUI

@onready var grid: GridContainer = $Control/Panel/GridContainer
@onready var spellPanel: Panel = $Control/SpellPanel
@onready var spellBook: Panel = $Control/SpellbookWindow

const SlotScene = preload("res://scenes/Inventory_and_Items/slot.tscn")

signal update_inventory

func _ready() -> void:
	visible = false
	
func refresh(inventory: Inventory) -> void: 
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	
	for item in inventory.items:
		var slot = SlotScene.instantiate()
		grid.add_child(slot)
		slot.set_item(item)
	
	var slots = spellPanel.get_children()

	for i in range(slots.size()):
		var slot = slots[i]
		if slot is Label:
			continue
		if i < inventory.spells.size():
			slot.set_item(inventory.spells[i])
		else:
			#slot.clear()  # optional: empty slot
			pass


func toggle(inventory: Inventory) -> bool:
	visible = !visible
	if visible:
		refresh(inventory)
		spellBook.refresh(inventory)
		#self.inventory = inventory
	return visible
	

func _on_spellbook_button_pressed() -> void:
	var window = $Control/SpellbookWindow
	window.visible = not window.visible


func _on_button_pressed(source: BaseButton) -> void:
	var selectedPanel = source.get_child(0)
	selectedPanel.visible = not selectedPanel.visible
	update_inventory.emit(source.Spell, selectedPanel.visible)
