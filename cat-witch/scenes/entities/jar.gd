extends "res://scenes/entities/pushable_object.gd"

var inAir = false
var broken = false
var previousVertVelocity = 0

signal jar_broken

func _physics_process(_delta: float) -> void:
	if not broken:
		var vY = abs(linear_velocity.y)
		if vY > 400 and abs(angular_velocity) < 4: # If falling fast enough and not spinning to quick, is in air
			inAir = true # If you skip spinning check it will think in air when wobbling
		elif abs(vY - previousVertVelocity) > 400 and inAir: # If stops rapidly (could adjust threshold) breaks
			objectBreak()
		else: # This is here for if you stop it slowly
			inAir = false
		previousVertVelocity = vY

func objectBreak() -> void:
	hide()
	set_collision_layer_value(1, false)
	set_collision_layer_value(6, false)
	set_collision_mask_value(1, false)
	# Something here for getting item that was inside?
	print("broke!")
	print(previousVertVelocity)
	print(linear_velocity.y)
	broken = true
	$JarBreak.play()
	jar_broken.emit(self) # Connect this to counter for broken jars?

func reset(target_pos: Vector2):
	inAir = false
	broken = false
	show()
	set_collision_layer_value(1, true)
	set_collision_layer_value(6, true)
	set_collision_mask_value(1, true)
	super.reset(target_pos)
