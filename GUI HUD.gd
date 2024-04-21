extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if owner.day == 1:
		$MiniTut.visible = true
	else:
		$MiniTut.visible = false



func _on_ingot_temperature_broadcast(temp, maxTemp):
	#rint(temp)
	#$ProgressBar.value = temp
	#$ProgressBar.max_value = maxTemp
	pass # Replace with function body.
