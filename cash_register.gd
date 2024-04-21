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
	
	
