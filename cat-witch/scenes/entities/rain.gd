extends Node2D

var cat: Node2D
@export var lightning_on = false
@export var target_path: Path2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.hide()
	$RainCollision.lightning_on = lightning_on
	if lightning_on:
		$Cloud.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$ColorRect.hide()
	if not target_path or not cat:
		return
	var curve = target_path.curve
	# 1. Get player position relative to the path's origin
	var local_player_pos = target_path.to_local(cat.global_position)
	# 2. Find the nearest offset (distance) on that path
	var closest_offset = curve.get_closest_offset(local_player_pos - Vector2(0, 250)) 
	# 3. Get the coordinates of that offset
	var curve_pos = curve.sample_baked(closest_offset)
	# 4. Move the rain to that global position
	global_position = target_path.to_global(curve_pos)

func _on_lightning_timer_timeout() -> void:
	# Draw Lightning
	var origin = $RainCollision.lightning.global_position
	var target = cat.global_position
	var direction = target - origin
	var distance = direction.length()
	
	$RainCollision.play_lightning_sound()
	$ColorRect.global_position = origin
	$ColorRect.size = Vector2(50, distance)
	$ColorRect.rotation = direction.angle() - PI/2
	$ColorRect.show()
	$AudioStreamPlayer.play()
	if $RainCollision.lightning:
			$RainCollision.lightning.reset_particles()
	
	if cat.wet and not cat.frozenSelf:
		cat.resetCat()
	else:
		$RainCollision/LightningTimer.start(5)
