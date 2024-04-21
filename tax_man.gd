extends CharacterBody2D


const speed = 200

var screen_size
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$Area2D/TaxManAnimatedSprite2D.play()

func _process(delta):
	velocity.y = -1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	move_and_slide()
	#position = position.clamp(Vector2.ZERO, screen_size)
	
	#if Input.is_action_just_pressed("interact"):
		#interacted.emit(station)
		
	if velocity.x != 0:
		$Area2D/TaxManAnimatedSprite2D.animation = "walk"
		$Area2D/TaxManAnimatedSprite2D.flip_v = false
		$Area2D/TaxManAnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y < 0:
		$Area2D/TaxManAnimatedSprite2D.animation = "walk"
	elif velocity.y > 0:
		$Area2D/TaxManAnimatedSprite2D.animation = "walk"
	else:
		$Area2D/TaxManAnimatedSprite2D.animation = "idle"

func start(pos):
	position = pos
	show()
	$Area2D/TaxManCollisionShape2D.disabled = false

