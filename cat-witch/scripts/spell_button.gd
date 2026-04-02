extends TextureButton

#enum SpellType { WIND, ICE, LIGHT, PLANT }
@export_enum("Wind Spell", "Freeze Spell", "Light Spell", "Plant Spell") var Spell: String
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_pressed() -> void:
	#$Panel.visible = not $Panel.visible
	pass
