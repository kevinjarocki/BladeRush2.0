extends Control

@onready var score = get_node("/root/ScoreSingleton")

func _ready():
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	pass

func _on_button_pressed():
	SilentWolf.Scores.save_score($TextEdit.text, score.score)
	get_tree().change_scene_to_file("res://menu.tscn")
	pass # Replace with function body.
