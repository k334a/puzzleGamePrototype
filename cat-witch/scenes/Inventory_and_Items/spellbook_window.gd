extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func refresh(inventory: Inventory) -> void:
	var all_children = get_children()
	for child in all_children:
		if not inventory.check_for_spell(child.Spell, true):
			child.hide()
		else:
			child.show()
		if inventory.check_for_spell(child.Spell):
			child.get_child(0).show()
		else:	
			child.get_child(0).hide()
		
		
