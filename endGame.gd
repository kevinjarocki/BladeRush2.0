extends Control

@onready var scoreSingleton = get_node("/root/ScoreSingleton")
@onready var labels = [$VBoxContainer/Label2,$VBoxContainer/Label3,$VBoxContainer/Label4,$VBoxContainer/Label5,$VBoxContainer/Label6]

var leaderboard = ""
var players = []
var scores = []


func _ready():
	SilentWolf.configure({
	"api_key": "7UNhUyzXAO2TnnCDn2v4h6hKxQAlDCSc9ODDHErW",
	"game_id": "BladeRush",
	"log_level": 1
  })
	$DeathSound.play()
	
	if scoreSingleton.fpsGamer:
		leaderboard = scoreSingleton.ldboard + "_FPS"
	else:
		leaderboard = scoreSingleton.ldboard + "_nonFPS"
	
	fakeOnReady()

func fakeOnReady():

	await get_tree().create_timer(.1).timeout 
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(5, leaderboard).sw_get_scores_complete
	$PlayerScore.text = "Score: " + str(scoreSingleton.score)
	
	for x in sw_result.scores:
		players.append(x["player_name"])
		scores.append(x["score"])
		
	
	for x in sw_result.scores.size():
		print(players)
		print(sw_result.scores.size())
		print(labels[x])
		labels[x].text = str(players[x]) + " Score: " + str(scores[x])
	
	var place = await SilentWolf.Scores.get_score_position(scoreSingleton.score, leaderboard).sw_get_position_complete
	$PlayerPosition.text = ("You've placed: " + str(place.position))
	
func _on_button_pressed():

	$Save.disabled = true
	SilentWolf.Scores.save_score($TextEdit.text, scoreSingleton.score, leaderboard)

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
