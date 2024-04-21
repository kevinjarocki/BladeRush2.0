extends Control

@onready var score = get_node("/root/ScoreSingleton")

#func _ready():
	#SilentWolf.Scores.get_high_scores().connect(sw_get_scores_complete)
#
  #func _on_registration_complete(sw_result: Dictionary) -> void:
  #if sw_result.success:
	#print("Registration succeeded!")
  #else:
	#print("Error: " + str(sw_result.error))

func _ready():
	SilentWolf.configure({
	"api_key": "7UNhUyzXAO2TnnCDn2v4h6hKxQAlDCSc9ODDHErW",
	"game_id": "BladeRush",
	"log_level": 1
  })
	fakeOnReady()

func fakeOnReady():
	#var fuckMe = (SilentWolf.Scores.get_scores())
	await get_tree().create_timer(.1).timeout 
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	
	var players = []
	var scores = []
	var labels = [$VBoxContainer/Label2,$VBoxContainer/Label3,$VBoxContainer/Label4,$VBoxContainer/Label5,$VBoxContainer/Label6]
	for x in sw_result.scores:
		players.append(x["player_name"])
		scores.append(x["score"])
	
	for x in labels.size():
		labels[x].text = str(players[x]) + " Score: " + str(scores[x])
	
func _on_button_pressed():

	$Label.text = "Score: " + str(score.score)
	print(SilentWolf.Scores.scores)

	SilentWolf.Scores.save_score($TextEdit.text, score.score)
	get_tree().change_scene_to_file("res://menu.tscn")
