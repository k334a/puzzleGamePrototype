extends Node2D

var cat: Node2D
@export var lightning_on = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.hide()
	$RainCollision.lightning_on = lightning_on

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ColorRect.hide()

func _on_lightning_timer_timeout() -> void:
	# Draw Lightning
	var origin = $RainCollision.lightning.global_position
	var target = cat.global_position
	var direction = target - origin
	var distance = direction.length()
	
	$ColorRect.global_position = origin
	$ColorRect.size = Vector2(50, distance)
	$ColorRect.rotation = direction.angle() - PI/2
	$ColorRect.show()
	if $RainCollision.lightning:
			$RainCollision.lightning.reset_particles()
	
	if cat.wet and not cat.frozenSelf:
		cat.resetCat()
	else:
		$RainCollision/LightningTimer.start(5)
