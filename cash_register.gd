extends AnimatedSprite2D

var drawAnim = false

func drawGoldValue(value):
	if (value > 0):
		$Label.text = "+" + str(value) + " G"
	else:
		$Label.text = "" + str(value) + " G"
	$Label.visible = true
	$Label.position.y = -9
	
	for x in 20:
		$Label.position.y -= 5
		await get_tree().create_timer(.05).timeout 
		
	$Label.visible = false
	
	


func _on_area_2d_area_entered(area):
	print(area.name)
	print("here")
	pass # Replace with function body.
