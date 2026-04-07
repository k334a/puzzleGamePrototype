extends CharacterBody2D

#Physics Variables
var run_speed = 350
var jump_speed = -1000
var gravity = 1500
var windResistance = 1500
var cutHeight = 0.5
var airtime = false
const MAX_PLAYER_SPEED = 360
#var outsideForce = 0

#Push Extras
const PUSH_FORCE = 50
const MAX_VELOCITY = 150

#Climb Extras
var wall_contact_coyote: float = 0.0
const WALL_CONTACT_COYOTE_TIME: float = 0.2
var look_dir_x: int = 1
var CLIMB_SPEED: float = 150
var CLIMB_EXIT_BOOST: Vector2 = Vector2(100, -100)
var is_climbing: bool = false
const WALL_JUMP_PUSH_FORCE: float = 400
var wall_jump_lock: float = 0.0

#Spell Variables
var windObject = load("res://scenes/spells/wind.tscn")
var spellCooldowns = [0.1, 0.1, 0.1, 0.1]

var onTrigger: interactive_area = null

#Inventory
@onready var inventory: Inventory = $Inventory

# For respawn:
@onready var startPosition: Vector2 = global_position

# Rain
var wet = 0
var frozenSelf = false

signal resetLevel
signal freezeTiles
signal unfurlPlant
signal nextLevel
signal recordScratch
signal freezeStream
signal unfreezeStream
signal unlockEntrance

func _input(event):
	if(event.is_action_released("jump")):
		if (velocity.y < 0):
			velocity.y *= cutHeight

func _ready() -> void:
	%PickupArea.area_entered.connect(_on_pickup_area_entered)
	$PointLight2D.hide()
	$FreezeCollisionShape2D.disabled = true

func resetCat() -> void:
	velocity = Vector2.ZERO
	%FreezeBubble.reset()
	global_position = startPosition
	$Spell1Cooldown.stop()
	$Spell2Cooldown.stop()
	$Spell3Cooldown.stop()
	$Spell4Cooldown.stop()
	resetLevel.emit()

func set_camera(top: int, right: int, bottom: int, left: int, zoom: Vector2) -> void:
	$Camera2D.limit_top = top
	$Camera2D.limit_right = right
	$Camera2D.limit_bottom = bottom
	$Camera2D.limit_left = left
	$Camera2D.zoom = zoom

func set_up_cat(spells: Array, items: Array, location: Vector2, knownSpells: Array):
	$Inventory.set_up_inventory(spells, items, knownSpells)
	if location != Vector2.ZERO:
		startPosition = location
		global_position = location

func _physics_process(delta):
	var right = Input.is_action_pressed('move_right')
	var left = Input.is_action_pressed('move_left')
	var jump = Input.is_action_pressed('jump')
	var down = Input.is_action_pressed('down')
	var crouch = Input.is_action_pressed('crouch')
	var interact = Input.is_action_just_pressed("interact")
	#var run = Input.is_action_pressed('run')
	var scratch = Input.is_action_just_pressed('scratch')
	var spell1 = Input.is_action_just_pressed('spell1')
	var spell2 = Input.is_action_just_pressed('spell2')
	var spell3 = Input.is_action_just_pressed('spell3')
	var spell4 = Input.is_action_just_pressed('spell4')
	
	if frozenSelf:
		right = false
		left = false
		jump = false
		down = false
		crouch = false
		#run = false
		scratch = false
		spell1 = false
		spell2 = false
		spell3 = false
		spell4 = false

	# Gravity Physics
	if not is_on_floor():
		#if velocity.x > 0:
			#velocity.x -= 350 * delta
		#elif velocity.x < 0:
			#velocity.x += 350 * delta
		if velocity.y < 0: # Moving UP
			$AnimatedSprite2D.play("jump")
		elif velocity.y > 0:              # Moving DOWN
			$AnimatedSprite2D.play("fall")
	else:
		if velocity.y == 0:
			$AnimatedSprite2D.play("idle")
	if abs(velocity.x) > MAX_PLAYER_SPEED:
		velocity.x -= sign(velocity.x) * 350 * delta
	# Movement
	if right:
		if velocity.x < 350:
			velocity.x = run_speed
		if $AnimatedSprite2D.flip_h == true:
			$Pivot.scale.x = 1
			$AnimatedSprite2D.flip_h = false
	
	if left:
		if velocity.x > -350:
			velocity.x = -run_speed
		if $AnimatedSprite2D.flip_h == false:
			$Pivot.scale.x = -1
			$AnimatedSprite2D.flip_h = true
	
	linearDampener(left, right)
	
	#Wall Collision
	if wall_jump_lock > 0.0:
		wall_jump_lock -= delta
	var on_wall: bool = %wall_ray.is_colliding() and TileMapCheck(%wall_ray, Vector2i(int(-%wall_ray.get_collision_normal().x) * 2, 0), "climbable")
	var on_wall_in_air: bool = on_wall and !is_on_floor()
	
	# Wall Sliding
	if on_wall_in_air and velocity.y > 0:
		wall_contact_coyote = WALL_CONTACT_COYOTE_TIME
		look_dir_x = int(-%wall_ray.get_collision_normal().x)
		velocity.y = 0
	else:
		if wall_contact_coyote > 0.0:
			wall_contact_coyote -= delta
		velocity.y += gravity * delta

	# Jumping
	if (is_on_floor() or wall_contact_coyote > 0.0) and jump and not crouch:
		velocity.y = jump_speed
		airtime = true
		if wall_contact_coyote > 0.0 and !is_on_floor():
			velocity.x = -look_dir_x * WALL_JUMP_PUSH_FORCE
			wall_jump_lock = 0.5

	# Freeze checking
	if %FreezeBubble.visible and %FreezeBubble.has_overlapping_bodies():
		%FreezeBubble.freeze_check()
	
	# Spells
	if spell1:
		#if $Inventory.spells[0] and $Spell1Cooldown.is_stopped():
		if $Spell1Cooldown.is_stopped():
			readSpell(left, right, down, jump, 0)
			$Spell1Cooldown.wait_time = spellCooldowns[0]
			$Spell1Cooldown.start()
	if spell2:
		if $Spell2Cooldown.is_stopped():
			readSpell(left, right, down, jump, 1)
			$Spell2Cooldown.wait_time = spellCooldowns[1]
			$Spell2Cooldown.start()
	if spell3:
		if $Spell3Cooldown.is_stopped():
			readSpell(left, right, down, jump, 2)
			$Spell3Cooldown.wait_time = spellCooldowns[2]
			$Spell3Cooldown.start()
	if spell4:
		if $Spell4Cooldown.is_stopped():
			readSpell(left, right, down, jump, 3)
			$Spell4Cooldown.wait_time = spellCooldowns[3]
			$Spell4Cooldown.start()

	# Crouching
	if crouch and is_on_floor():
		velocity.x = 0
		$AnimatedSprite2D.scale = Vector2(1.5, 0.5)
		$AnimatedSprite2D.offset.y = 50
	else:
		$AnimatedSprite2D.scale = Vector2(1, 1)
		$AnimatedSprite2D.offset.y = 0
	
	# Scratching
	if scratch:
		$Pivot/ClawArea/CollisionShape2D.disabled = false
		if onTrigger and onTrigger.areaType == "Scratch":
			onTrigger.scratch()
			recordScratch.emit(onTrigger)
	else:
		$Pivot/ClawArea/CollisionShape2D.disabled = true
	
	# Pushing
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_crate = collision.get_collider()
		if not is_instance_valid(collision_crate):
			break
		if collision_crate.is_in_group("pushable") and abs(collision_crate.get_linear_velocity().x) < MAX_VELOCITY:
			collision_crate.apply_central_impulse(collision.get_normal() * -PUSH_FORCE)
		if collision_crate.is_in_group("box"): # We have a problem with delta correction pushing things through walls
			if spell1 or spell2: # Just to see if it works
				collision_crate.apply_impulse(velocity)
				apply_outside_force(collision_crate.linear_velocity * delta)
	
	if interact and onTrigger and onTrigger.areaType == "Entrance":
		print(onTrigger.entranceLevel)
		if onTrigger.unlocksEntrance:
			unlockEntrance.emit(onTrigger.entranceLevel)
		nextLevel.emit(onTrigger.entranceLevel, onTrigger.entranceLocation, $Inventory.spells, $Inventory.items, $Inventory.spellsKnown)
	elif interact and onTrigger and onTrigger.areaType == "Button":
		print("button clicked")
		if onTrigger.button == "Reveal" or onTrigger.button == "LeverToggle":
			var catTrigger = onTrigger
			onTrigger.click()
			if catTrigger.destroyed:
				recordScratch.emit(catTrigger)
		elif onTrigger.button == "Spigot" and onTrigger.pressed == false:
			onTrigger.pressed = true
			freezeStream.emit(onTrigger.buttonTiles, onTrigger.buttonLayer)
		elif onTrigger.button == "Spigot":
			onTrigger.pressed = false
			unfreezeStream.emit(onTrigger.buttonTiles.map(func(tile): return tile.x), onTrigger.buttonLayer)
	elif interact and onTrigger and onTrigger.areaType == "UseItem":
		if check_for_item(onTrigger.requiredItem):
			onTrigger.useItem()
	
	move_and_slide()

func apply_outside_force(forceVector):
	velocity.x += forceVector.x
	velocity.y += forceVector.y

func linearDampener(left, right):
	var on_ice: bool = false
	if not left and not right:
		var body = %floor_ray.get_collider()
		if body and body is TileMapLayer:
			var tile: Vector2i = body.local_to_map(body.to_local(%floor_ray.global_position))
			tile = tile - Vector2i(0, -1)
			var data = check_data(tile, body, "terrain_type")
			if data == "ice":
				on_ice = true
		if on_ice:
			velocity.x -= velocity.x * 0.01
		elif is_on_floor():
			if frozenSelf:
				velocity.x -= velocity.x * 0.01
			else:
				velocity.x -= velocity.x * 1	
			
# Read Tilemap Helper
func TileMapCheck(object, offset, flag):
	var body = object.get_collider()
	if body is TileMapLayer:
		var centerTile: Vector2i = body.local_to_map(body.to_local(object.global_position)) #Gets a tile in local coordinates of TileMapLayer
		var tile: Vector2i = centerTile + offset
		var data = check_data(tile, body, flag)
		if data:
			return true
	return false

# This is duplicated in freeze_bubble and world
func check_data(tile: Vector2i, layer: TileMapLayer, attribute: String) -> Variant:
	var data: TileData = layer.get_cell_tile_data(tile)
	if data and data.has_custom_data(attribute):
		return data.get_custom_data(attribute)
	return null

# Spell Functions
func readSpell(left_input, right_input, down_input, up_input, index):
	if not $Inventory.spells[index]:
		return # Ends the function if there is no valid spell
	
	# Compute current key presses into vector
	var lookVector = Vector2.ZERO
	if left_input:
		lookVector.x -= 1
	if right_input:
		lookVector.x += 1
	if down_input:
		lookVector.y += 1
	if up_input:
		lookVector.y -= 1
	var magnitude = sqrt(pow(lookVector.x, 2) + pow(lookVector.y, 2))
	if not magnitude:
		lookVector = Vector2($Pivot.scale.x, 0)
	else:
		lookVector = Vector2(lookVector.x / magnitude, lookVector.y / magnitude)
	
	var spell_list = {
		0: func(): wind(lookVector); spellCooldowns[index] = 2,
		1: func(): freeze(); spellCooldowns[index] = 7,
		2: func(): light(); spellCooldowns[index] = 1,
		3: func(): spellCooldowns[index] = plant(),
	}
	
	var spell = $Inventory.spells[index].spell_type
	
	spell_list[spell].call()

func _spell_cooldown_ended(index: int):
	spellCooldowns[index] = false

func freeze():
	%FreezeBubble.startFreeze()
	if wet:
		frozenSelf = true
		var block_timer = Timer.new()
		add_child(block_timer)
		var unfreeze = func(): 
			frozenSelf = false
			$FreezeCollisionShape2D.disabled = true;
			floor_max_angle = deg_to_rad(45)
			block_timer.queue_free()
			
		block_timer.timeout.connect(func(): unfreeze.call())
		block_timer.one_shot = true
		block_timer.start(5)
		$FreezeCollisionShape2D.disabled = false
		floor_max_angle = deg_to_rad(15)

func wind(lookVector):
	velocity.x = 0
	velocity.y = 0
	var outsideForce = 1000
	var windScene = windObject.instantiate()
	windScene.position = Vector2(position.x, position.y - 50)
	windScene.get_child(0).force = -lookVector * 100
	add_sibling(windScene)
	apply_outside_force(lookVector * outsideForce)
	#windScene.get_child(0).get_child(-1).play

func light():
	if $PointLight2D.visible:
		$PointLight2D.hide()
	else:
		$PointLight2D.show()
		await get_tree().create_timer(8, false).timeout
		$PointLight2D.hide()

func plant() -> float:
	if onTrigger and onTrigger.areaType == "Plant":
		unfurlPlant.emit(onTrigger)
		return 5.0
	return 0.1

#handler
func _on_pickup_area_entered(area: Area2D) -> void:
	if not area.is_in_group("pickup"):
		return
	
	var try_pickup = inventory.add_item(area.item)
	
	if try_pickup:
		if area.item.isSpell:
			inventory.add_spell(area.item)
		area.queue_free()
	
	else:
		print("Inventory full!")

# when spell is picked up, move it to the first spell slot. allow movement between slots

func _on_water_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		if %FreezeBubble.visible: # If player manages to hit water while freeze is active because they were too fast, checks extra inner corners in bubble
			%FreezeBubble.freeze_check(true)
		else:
			resetCat()

func _on_freeze_bubble_freeze_tile(flatWater: Array[Vector2i], flatIce: Array[Vector2i], fallingWater: Dictionary[int, Array], fallingIce: Array[int]) -> void:
	freezeTiles.emit(flatWater, flatIce, fallingWater, fallingIce)

func _on_head_check_body_exited(body: Node2D) -> void:
	if body.is_in_group("pushable"):
		body.linear_velocity.y *= 0.5
		body.collision_layer += 1 # Re-add box to collision Layer

func _on_head_check_body_entered(body: Node2D) -> void:
	if body.is_in_group("pushable"): # Check type of box
		self.velocity.y *= 0.5
		body.collision_layer -= 1 # Remove box from layer allow move_and_slide()

func check_for_spell(spell: String) -> bool:
	return $Inventory.check_for_spell(spell)

func check_for_item(item: String) -> bool:
	return $Inventory.check_for_item(item)

func _on_claw_area_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		var centerTile: Vector2i = body.local_to_map(body.to_local($Pivot/ClawArea/CollisionShape2D.global_position)) #Gets a tile in local coordinates of TileMapLayer
		var top_tile: Vector2i = centerTile - Vector2i(0, 1)
		var tile = top_tile
		for i in range(2):
			for j in range(3):
				var data = check_data(tile, body, "removable")
				if data:
					body.erase_cell(tile)
				tile += Vector2i(0, 1)
			tile = top_tile + Vector2i($Pivot.scale.x, 0)

# Immediately Teleport cat to target location
func instantEntrance(area: interactive_area) -> void:
	print(area.entranceLevel)
	if area.unlocksEntrance:
		unlockEntrance.emit(area.entranceLevel)
	nextLevel.emit(area.entranceLevel, area.entranceLocation, $Inventory.spells, $Inventory.items, $Inventory.spellsKnown)

# Set Respawn Point
func _on_respawn_checker_area_entered(area: Area2D) -> void:
	var body = area
	if body and body is Area2D and body.is_in_group("RespawnAnchor"):
		startPosition = body.global_position
