extends Control

# Inside Popups.gd
func ItemPopup(slot_node: Control, item: Item):
	#%ItemPopup/VBoxContainer/NameLabel.text = item.item_name
	if item != null:
		set_popup_values(item)
		%ItemPopup.size = Vector2i(170, 0)
	
	var slot_global_pos = slot_node.global_position
	var slot_size = slot_node.size
	
	var popup_size = %ItemPopup.size
	var final_pos = Vector2i()
	
	if slot_global_pos.x <= get_viewport_rect().size.x / 2:
		final_pos = Vector2i(slot_global_pos.x + slot_size.x -35, slot_global_pos.y)
	else:
		final_pos = Vector2i(slot_global_pos.x - popup_size.x, slot_global_pos.y)
	
	%ItemPopup.popup(Rect2i(final_pos, popup_size))

func HideItemPopup():
	%ItemPopup.hide()
	
func set_popup_values(item: Item):
	%Name.text = item.name
	%Attribute1Value.text = str(item.damage)
	%Attribute2Value.text = str(item.strength)
	%Attribute3Value.text = set_text_effect(item.rarity)
	%Attribute4Value.text = item.description
	
func set_text_effect(rarity: String):
	var text: String = rarity
	match rarity:
		"basic": 
			text = "[wave amp=5 freq=8]" + text
		"rare": 
			text = "[tornado radius=1.8 freq=3][color=#fc037b]" + text
		"legendary": 
			text = "[wave amp=10 freq=10][rainbow]" + text
	
	return text
