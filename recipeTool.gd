extends Control
var tempRecipeArray = []
var recipeTool = false
@export var Weapon = Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if (recipeTool and Input.is_action_just_pressed("click")):
		tempRecipeArray.append(event.position)

func _on_button_pressed():
	tempRecipeArray.pop_back()
	recipeTool = !recipeTool
	if !recipeTool:
		print("[")
		for x in tempRecipeArray:
			print("Vector2",x,",")
		print("]")
