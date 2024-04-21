extends Control



func _on_play_pressed():
	get_tree().change_scene_to_file("res://shop.tscn")




func _on_options_pressed():
	$Thwak.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://options_menu.tscn")



func _on_quit_pressed():
	$Thwak.play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()
