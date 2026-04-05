extends Control

# Inside Popups.gd
func ItemPopup(slot_node: Control, item: Item):
	#%ItemPopup/VBoxContainer/NameLabel.text = item.item_name
	if item != null:
		set_popup_values(item)
		%ItemPopup.size = Vector2i(170, 0)
	
	var slot_global_pos = slot_node.global_position
	#var slot_size = slot_node.size
	
	var popup_size = %ItemPopup.size
	var final_pos = Vector2i()
	
	# Temporary math since we know its just the last one
	if slot_global_pos.x / 2 + %ItemPopup.size.x >= get_viewport_rect().size.x - 50:
		final_pos = Vector2i(slot_global_pos.x, slot_global_pos.y + 100)
	else:
		final_pos = Vector2i(slot_global_pos.x - popup_size.x, slot_global_pos.y)
	
	%ItemPopup.popup(Rect2i(final_pos, popup_size))

func HideItemPopup():
	%ItemPopup.hide()
	
func set_popup_values(item: Item):
	%Name.text = item.name
	if item.duration == 0.0:
		%Attribute1Value.text = "Single Effect"
	else:
		%Attribute1Value.text = str(item.duration) + " Seconds"
	%Attribute2Value.text = str(item.cooldown) + " Seconds"
	%Attribute3Value.text = set_text_effect(item.rarity)
	%Attribute4Value.text = item.description
	
func set_text_effect(rarity: String):
	var text: String = rarity
	match rarity:
		"Basic": 
			text = "[wave amp=5 freq=8]" + text
		"Rare": 
			text = "[tornado radius=1.8 freq=3][color=#fc037b]" + text
		"Legendary": 
			text = "[wave amp=10 freq=10][rainbow]" + text
	
	return text
