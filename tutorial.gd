extends Control

var buttonPressedCount = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainGameImage.visible = true
	$TutorialDialog1.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_button_pressed():
	$Thwak.play()

	$MainGameImage.visible = false
	$TutorialDialog1.visible = false
	if buttonPressedCount == 1:
		$MolMolImage.visible = true
		$TutorialDialog2.visible = true
	if buttonPressedCount == 2:
		$MolMolImage.visible = false
		$TutorialDialog2.visible = false
		$FurnaceImage.visible = true
		$TutorialDialog3.visible = true
	if buttonPressedCount == 3:
		$FurnaceImage.visible = false
		$TutorialDialog3.visible = false
		$AnvilImage.visible = true
		$TutorialDialog4.visible = true
	
	buttonPressedCount += 1

