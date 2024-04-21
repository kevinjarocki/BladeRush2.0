
extends CharacterBody2D


signal interacted(station)
signal departed(body)

var station = null
var isFrozen = false

@export var speed = 400

var screen_size
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$Area2D/AnimatedSprite2D.animation = "Idle"
	$Area2D/AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not isFrozen:
		velocity = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		
		move_and_slide()
		position = position.clamp(Vector2.ZERO, screen_size)
		
		if Input.is_action_just_pressed("interact"):
			interacted.emit(station)
		
		if velocity.x != 0:
			$Area2D/AnimatedSprite2D.animation = "walk"
			$Area2D/AnimatedSprite2D.flip_v = false
			$Area2D/AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y < 0:
			$Area2D/AnimatedSprite2D.animation = "up"
		elif velocity.y > 0:
			$Area2D/AnimatedSprite2D.animation = "down"

		else:
			if station != null:
				if station.owner:
					if station.owner.name == "Anvil":
						$Area2D/AnimatedSprite2D.animation = "swing"
					if station.owner.name == "Forge":
						$Area2D/AnimatedSprite2D.animation = "fiddling"
					if station.owner.name == "OreBox":
						$Area2D/AnimatedSprite2D.animation = "fiddling"
					if station.owner.name == "CashRegister":
						$Area2D/AnimatedSprite2D.animation = "fiddling"
			else:
				$Area2D/AnimatedSprite2D.animation = "Idle"

		

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_area_2d_body_entered(body):
	station = body
	print(station.name)

func _on_area_2d_body_exited(body):
	station = null
	if body.owner:
		if body.owner.name == "Anvil":
			departed.emit(body)
	
func freeze():
	isFrozen = true
	
func unFreeze():
	isFrozen = false

func increaseSpeed(value):
	speed += value
