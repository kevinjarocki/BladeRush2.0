extends Control

var buttonPressedCount = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	$MainGameImage.visible = true
	$TutorialDialog1.visible = true
	$NextButton.visible = true
	$MolMolImage.visible = false
	$TutorialDialog2.visible = false
	$FurnaceImage.visible = false
	$TutorialDialog3.visible = false
	$AnvilImage.visible = false
	$TutorialDialog4.visible = false
	$CompletedImage.visible = false
	$TutorialDialog5.visible = false
	$ChaChingImage.visible = false
	$TutorialDialog6.visible = false
	$ShopImage.visible = false
	$TutorialDialog7.visible = false
	$TaxmanImage.visible = false
	$TutorialDialog8.visible = false
	$MainMenuButton.visible = false

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
	if buttonPressedCount == 4:
		$AnvilImage.visible = false
		$TutorialDialog4.visible = false
		$CompletedImage.visible = true
		$TutorialDialog5.visible = true
	if buttonPressedCount == 5:
		$CompletedImage.visible = false
		$TutorialDialog5.visible = false
		$ChaChingImage.visible = true
		$TutorialDialog6.visible = true
	if buttonPressedCount == 6:
		$ChaChingImage.visible = false
		$TutorialDialog6.visible = false
		$ShopImage.visible = true
		$TutorialDialog7.visible = true
	if buttonPressedCount == 7:
		$ShopImage.visible = false
		$TutorialDialog7.visible = false
		$TaxmanImage.visible = true
		$TutorialDialog8.visible = true
		$NextButton.visible = false
		$MainMenuButton.visible = true
	
	buttonPressedCount += 1



func _on_main_menu_button_pressed():
	$Thwak.play()
	get_tree().change_scene_to_file("res://menu.tscn")
