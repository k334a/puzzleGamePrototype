extends TextureButton

#enum SpellType { WIND, ICE, LIGHT, PLANT }
@export_enum("Wind Spell", "Freeze Spell", "Light Spell", "Plant Spell") var Spell: String
var selected = false

func _on_pressed() -> void:
	#$Panel.visible = not $Panel.visible
	pass
