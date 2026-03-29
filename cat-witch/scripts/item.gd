extends Resource
class_name Item

# Syntax:  var  name: Type = default_value
# The ": Type" prevents bugs. If accidentally put the wrong kind of value in, errors.

# @export
# Adding @export before a var makes it show up in the Godot Inspector when this resource is selected.
@export var name: String = "item"
@export var description: String = "hidden"
@export var icon: Texture2D = null
@export var damage: int = 0
@export var cooldown: float = 1.0
@export var is_unlocked: bool = false
@export var rarity: String = "basic"
@export var strength: int = 0
@export var isSpell: bool = true

# type 0 = wind, type 1 = ICE
# SpellType.WIND or SpellType.ICE.

enum SpellType { WIND, ICE, LIGHT, PLANT }

# Now you can make a property that uses it:
@export var spell_type: SpellType
