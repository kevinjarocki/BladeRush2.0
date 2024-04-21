extends Control

var buttonPressedCount = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainGameImage.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_button_pressed():
	buttonPressedCount += 1
	
	pass # Replace with function body.
