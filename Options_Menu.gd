extends Control




func _on_back_to_menu_button_pressed():
	$ThwakToMainMenu.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_mute_check_toggled(toggled_on):
	var music_bus = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(music_bus, not AudioServer.is_bus_mute(!toggled_on))



func _on_option_button_item_selected(index):
	var index_selected_id = $MarginContainer/VBoxContainer/OptionButton.get_item_id(index)
	if (index_selected_id == 0):
		get_viewport().content_scale_size = Vector2(640,480)
	if (index_selected_id == 1):
		get_viewport().content_scale_size = Vector2(1152,640)
	if (index_selected_id == 2):
		get_viewport().content_scale_size = Vector2(1280,720)
	if (index_selected_id == 3):
		get_viewport().content_scale_size = Vector2(1920,1080)


func _on_ready():
	var viewport = get_viewport()
	if (viewport.content_scale_size == Vector2i(640,480)):
		$MarginContainer/VBoxContainer/OptionButton.select(0)
	if (viewport.content_scale_size == Vector2i(1152,640)):
		$MarginContainer/VBoxContainer/OptionButton.select(1)
	if (viewport.content_scale_size == Vector2i(1280,720)):
		$MarginContainer/VBoxContainer/OptionButton.select(2)
	if (viewport.content_scale_size == Vector2i(1920,1080)):
		$MarginContainer/VBoxContainer/OptionButton.select(3)
