
extends CharacterBody2D

signal interacted(station)

var station = Area2D
var want = "dagger"

@export var speed = 400

var screen_size
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$Area2D/AnimatedSprite2D.play()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#velocity = Vector2.ZERO
	velocity.y = -1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	move_and_slide()
	#position = position.clamp(Vector2.ZERO, screen_size)
	
	#if Input.is_action_just_pressed("interact"):
		#interacted.emit(station)
		
	if velocity.x != 0:
		$Area2D/AnimatedSprite2D.animation = "Walk_Hands_Down"
		$Area2D/AnimatedSprite2D.flip_v = false
		$Area2D/AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y < 0:
		$Area2D/AnimatedSprite2D.animation = "Walk_Hands_Up"
	elif velocity.y > 0:
		$Area2D/AnimatedSprite2D.animation = "Walk_Hands_Down"
	else:
		$Area2D/AnimatedSprite2D.animation = "Idle_Hands_Down"

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_area_2d_body_entered(body):
	station = body

func _on_area_2d_body_exited(body):
	station = null
	
func ExitShop():
	set_velocity(Vector2(-10,0))
	$Timer.start()

func _on_timer_timeout():
	queue_free()
