extends Node 
class_name Inventory

@export var inventory_size := 8

signal updated

var items: Array
var spells: Array
var spellsKnown: Array

func _ready():
	items = []
	items.resize(inventory_size)
	spells.resize(4)

# Trying own function instead, this seems to work, but when you go between levels any non-selected
# spells end up out of order, and give null errors when you try to select them
func set_up_inventory(spellList: Array, itemList: Array, knownList: Array) -> void:
	for spell: Item in spellList:
		add_spell(spell)
	for item: Item in itemList:
		add_item(item)
	for knownSpell: Item in knownList:
		if not check_for_spell(knownSpell.name):
			spellsKnown.append(knownSpell)

func add_item(item: Item) -> bool:
	for i in range(items.size()):
		if items[i] == null:
			items[i] = item
			updated.emit(self)
			print("test, item added to slot ", i)
			return true # end loop, found empty space for item
	return false # inventory full

func add_spell(item: Item) -> bool:
	for i in range(spells.size()):
		if spells[i] == null:
			spells[i] = item
			spellsKnown.append(item)
			updated.emit(self)
			print("test, spell added to spell slot ", i)
			return true
	return false

func remove_spell(spell_name: String) -> bool:
	for i in range(spells.size()):
		if spells[i] and spells[i].name == spell_name:
			spells[i] = null
			updated.emit(self)
			print("test, spell removed from spell slot ", i)
			return true
	return false
	
func remove_item(index: int) -> bool: #test if you can remove an item
	if items[index] != null:
		return true
	items[index] = null
	return false

func check_for_spell(spellName: String, known: bool=false) -> bool:
	var spellList = []
	if known:
		spellList = spellsKnown
	else:
		spellList = spells
	for spell: Item in spellList:
		if spell and spell.name == spellName:
			return true
	return false

func check_for_item(itemName: String) -> bool:
	for item: Item in items:
		if item and item.itemIDName == itemName:
			return true
	return false
