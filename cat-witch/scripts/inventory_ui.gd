extends CanvasLayer
class_name InventoryUI

@onready var grid: GridContainer = $Control/Panel/GridContainer
@onready var spellPanel: Panel = $Control/SpellPanel
var totalJars: int = 0
var brokenJars: int = 0
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

func update_vases(broke: bool, total: int=0) -> void:
	if broke:
		brokenJars += 1
		if total == 0:
			total = totalJars
	else:
		print("Broke false, total: ", str(total))
		totalJars = total
	$Control/RichTextLabel.text = "Vases Broken: " + String.num_int64(brokenJars) + "/" + String.num_int64(total)

func show_jars() -> void:
	show()
	$Control/Panel.hide()
	$Control/SpellPanel.hide()
	$Control/CLabel.hide()
	$Control/XLabel.hide()
	$Control/ZLabel.hide()
	$Control/VLabel.hide()
	$Control/HBoxContainer.hide()
	$Control/SpellbookButton.hide()
	$Control/SpellbookWindow.hide()
	await get_tree().create_timer(2, false).timeout
	$Control/Panel.show()
	$Control/SpellPanel.show()
	$Control/CLabel.show()
	$Control/XLabel.show()
	$Control/ZLabel.show()
	$Control/VLabel.show()
	$Control/HBoxContainer.show()
	$Control/SpellbookButton.show()
	hide()
	

func _on_spellbook_button_pressed() -> void:
	var window = $Control/SpellbookWindow
	window.visible = not window.visible


func _on_button_pressed(source: BaseButton) -> void:
	var selectedPanel = source.get_child(0)
	selectedPanel.visible = not selectedPanel.visible
	update_inventory.emit(source.Spell, selectedPanel.visible)
