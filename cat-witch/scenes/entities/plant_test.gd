extends AnimatableBody2D

@export_range(0, 5, 1, "or_greater") var scratchesToDestroy: int = 1
@export_range(0, 5, 1, "or_greater") var damageFramesOffset: int = 0
@export var lightUpColour: Color
@export var plantAnimations: SpriteFrames
@export var damageFrameOffset: int
var damage: int = 0

func _ready() -> void:
	$InteractionSprite.interactionType = "Plant"
	$InteractionSprite.plant = self
	$InteractionSprite.plantColour = lightUpColour
	$InteractionSprite.scratchValue = scratchesToDestroy
	$InteractionSprite.scratchType = "Plant"
	$InteractionSprite.scratchValue = scratchesToDestroy
	$InteractionSprite.sprite_frames = plantAnimations
	$InteractionSprite.damageFrameOffset = damageFramesOffset

func unfurl() -> void:
	if damage == 0:
		$AnimationPlayer.play("unfurl")
	else:
		$AnimationPlayer.play("unfurl_damage_" + String.num(damage))
	$InteractionSprite.plantUnfurled()

func furlup() -> void:
	if damage == 0:
		$AnimationPlayer.play("furlup")
	else:
		$AnimationPlayer.play("furlup_damage_" + String.num(damage))
	$InteractionSprite.plantFurled()

func reset() -> void:
	show()
	$CollisionPolygon2D.disabled = false
	$AnimationPlayer.play("RESET")
	$InteractionSprite.resetPlant()
	damage = 0

func _on_interactive_sprite_damage_self() -> void:
	damage += 1

func _on_interactive_sprite_destroyed() -> void:
	$CollisionPolygon2D.disabled = true
	hide()
