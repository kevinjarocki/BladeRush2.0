extends Node2D

@export var money = 0
@export var day = 1
@export var dayTimer = 0.00
@export var endDayTime = 80
@export var activeRecipe = "Awaiting Order"
@export var activeMaterial = ""
@export var minigame: PackedScene

@export var heatingMod = 0
@export var coolingMod = 0
@export var autoMolmol = false

var heatingModInc = 0
var coolingModInc = 0
var playerSpeedModInc = 0

var heatingModCost = [10,12,15,20,25,35,45,50,60,80,100]
var coolingModCost = [10,12,15,20,25,35,45,50,60,80,100]
var playerSpeedModCost = [10,12,15,20,25,35,45,50,60,80,100]
var autoMolmolCost = 150

@export var goldenHammer = false
@export var bottledFire = true
@export var kingsSigil = false
@export var beBackIn5 = false
@export var goldenHammerActive = false
@export var bottledFireActive = false
@export var kingsSigilActive = false
@export var beBackIn5Active = false
@export var goldenHammerCost = 10
@export var bottledFireCost = 10
@export var kingsSigilCost = 25
@export var beBackIn5Cost = 50

var taxManHere = false
var taxPayed = false
var taxMan = InstancePlaceholder
var taxesOwed = 10*pow(day,1.1)
var ingotNode = null
var gameFinished = false

var recipeBook = {

	"Dagger" : {"points": [Vector2(569, 139),Vector2(628, 191),Vector2(654, 237),Vector2(660, 291),Vector2(660, 293)], 
	"name": "dagger", "perfectRange": 5, "punishRate": 0.2, "value" : 3},
	
	"Scimitar" : {"points": [Vector2(586, 279),Vector2(545, 329),Vector2(523, 369),Vector2(506, 381),Vector2(535, 332),Vector2(580, 277),Vector2(484, 394),Vector2(516, 335),Vector2(546, 285),Vector2(611, 244)], 
	"name": "scimitar","perfectRange": 5, "punishRate": 0.1, "value" : 2},
	
	"Axe" : {"points": [Vector2(635, 355),Vector2(596, 326),Vector2(559, 293),Vector2(524, 264),Vector2(626, 368),Vector2(648, 337),Vector2(504, 298),Vector2(507, 270),Vector2(524, 253),Vector2(552, 239),Vector2(547, 368),Vector2(568, 397),Vector2(597, 365)], 
	"name": "axe", "perfectRange": 10, "punishRate": 0.5, "value" : 3},
	
	"Falchion" : {"points": [Vector2(602, 276),Vector2(504, 387),Vector2(627, 324),Vector2(581, 234),Vector2(574, 408),Vector2(492, 382),Vector2(623, 261),Vector2(554, 350),Vector2(587, 257),Vector2(563, 391),Vector2(520, 372),Vector2(531, 356),Vector2(531, 355),Vector2(624, 235),Vector2(637, 235)], 
	"name": "falchion", "perfectRange": 5, "punishRate": 0.4, "value" : 4},
	
	"Longsword" : {"points": [Vector2(519, 374),Vector2(658, 264),Vector2(562, 324),Vector2(562, 325),Vector2(620, 252),Vector2(557, 368)], 
	"name": "longsword", "perfectRange": 8, "punishRate": 0.1, "value" : 1},
	
	"Rapier" : {"points": [Vector2(635, 248),Vector2(635, 248),Vector2(635, 248),Vector2(600, 292),Vector2(600, 292),Vector2(600, 292),Vector2(563, 355),Vector2(563, 355),Vector2(563, 355),Vector2(526, 413),Vector2(526, 413),Vector2(526, 413)], 
	"name": "rapier", "perfectRange": 3, "punishRate": 1, "value" : 3},
	
	"Sabre" : {"points": [Vector2(503, 367),Vector2(655, 283),Vector2(543, 326),Vector2(537, 367),Vector2(537, 368),Vector2(642, 258),Vector2(600, 301),Vector2(602, 300)], 
	"name": "sabre", "perfectRange": 6, "punishRate": 0.5, "value" : 2},
	
	"Tashi" : {"points": [Vector2(566, 287),Vector2(567, 287),Vector2(527, 360),Vector2(581, 247),Vector2(526, 327),Vector2(525, 328),Vector2(640, 258),Vector2(515, 364),Vector2(591, 237),Vector2(474, 412),Vector2(428, 387),Vector2(651, 240),Vector2(530, 370),Vector2(530, 371)], 
	"name": "tashi", "perfectRange": 15, "punishRate": 1.5, "value" : 2}
}

var materialBook = {
	"Tin" : {"name": "tin", "coolRate" : 10, "heatRate" : 25, "idealTemp": 7500, "idealTempRange": 1200, "valueMod": 2, "cost": 0},
	"Iron" : {"name": "iron", "coolRate" : 8, "heatRate" : 25, "idealTemp": 6600, "idealTempRange": 800, "valueMod": 3, "cost": 1},
	"Bronze" : {"name": "bronze", "coolRate" : 4, "heatRate" : 25, "idealTemp": 4000, "idealTempRange": 1000, "valueMod": 4, "cost": 1},
	"Gold": {"name": "gold", "coolRate" : 20, "heatRate" : 50, "idealTemp": 3000, "idealTempRange": 500, "valueMod": 6, "cost": 1},
	"Rune": {"name": "rune", "coolRate" : 15, "heatRate" : 40, "idealTemp": 5500, "idealTempRange": 400, "valueMod": 7, "cost": 1},
	"Mithril": {"name": "mithril", "coolRate" : 50, "heatRate" : 10, "idealTemp": 5000, "idealTempRange": 1000, "valueMod": 7, "cost": 1},
	"Caledonite": {"name": "caledonite", "coolRate" : 4, "heatRate" : 20, "idealTemp": 7000, "idealTempRange": 200, "valueMod": 8, "cost": 1}

}

func _process(delta):
	
	$"GUI HUD/DayTimer".value = (dayTimer/endDayTime)*100
	dayTimer += delta
	
	if dayTimer > endDayTime and !$EndDay.visible:
		resetDay()
		$EndDay.endDay(day, money)
	
	$"GUI HUD/ActiveRecipe".text = ("Active Recipe: " + str(activeMaterial) + " " + str(activeRecipe))
	$"GUI HUD/DayCount".text = ("Day " + str(day))
	$"GUI HUD/MoneyCount".text = ("Gold: " + str(money))
		
	if(ingotNode != null):
		var temp = ingotNode.temperature
		$"GUI HUD/ProgressBar".value = ((temp/ingotNode.maxTemp)*100)

	else:
		var temp = 0
		$"GUI HUD/ProgressBar".value = temp

	$"GUI HUD/Golden Hammer".disabled = !goldenHammer 
	$"GUI HUD/Kings Sigil".disabled = !kingsSigil
	$"GUI HUD/Be Back in 5".disabled = !beBackIn5 
	$"GUI HUD/Bottled Fire".disabled = !bottledFire

func _on_player_interacted(station):
	
	#If player is at an interactable station -> Go to a function for each station
	if station:
		if !station.owner:
			pass
		elif station.owner.name == "Anvil":
			playerAtAnvil()
		elif station.owner.name == "Forge":
			playerAtForge()
		elif station.owner.name == "OreBox":
			playerAtOreBox()
		elif station.owner.name == "TrashCan":
			playerAtTrashCan()
		elif station.owner.name == "CashRegister":
			playerAtCashRegister()
			
	else:
		print("No station nearby")
	
func playerAtAnvil():
	if (ingotCheck()):
		$Player.freeze()
		var ingotNode = ingotCheck()
		if !gameFinished:
			print("take my ingot")
			$Player.remove_child(ingotNode)
			$AnvilGame.add_child(ingotNode)
			$AnvilGame.move_child(ingotNode,1)
			$AnvilGame.summonMinigame(ingotNode)
			
		else:
			print("dont take my ingot")
		
		$Player.unFreeze()
	else:
		print("no ingot")
	
func playerAtForge():
	
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = $Forge.position + Vector2(80,100)
	var space = get_world_2d().direct_space_state
	
	for x in get_world_2d().direct_space_state.intersect_point(query):

		if x.collider.owner.is_in_group("ingot"):
			remove_child(x.collider.owner)
			$Player.add_child(x.collider.owner)
			x.collider.owner.position = Vector2(20,10)
			x.collider.owner.isForge = false
			$Forge.pause()
			$Forge.set_frame_and_progress(0,0)
			return

	if ingotCheck():
		ingotNode = ingotCheck()
		$Player.remove_child(ingotNode)
		add_child(ingotNode)
		ingotNode.name = "Ingot"
		ingotNode.position = $Forge.position + Vector2(80,100)
		ingotNode.isForge = true
		$Forge.play()
		$Fire.play()
			
	else:
		print("Nothing to do, player does not have ingot")

func playerAtOreBox():
	if !ingotCheck() and activeRecipe != "Awaiting Order" and !taxManHere:
		
		$OreBox.play()
		$Ferret.play()
		$Dirt.play()
	
		gameFinished = false
		ingotNode = load("res://ingot.tscn").instantiate()
		$Player.add_child(ingotNode)
		ingotNode.position = Vector2(20,10)
		ingotNode.scale = Vector2(1.5,1.5)
		print ("Picked up ingot")
		
		ingotNode.recipeProperties = recipeBook[activeRecipe]
		ingotNode.materialProperties = materialBook[activeMaterial]
		ingotNode.heatingMod = heatingMod
		ingotNode.coolingMod = coolingMod
		
		ingotNode.SetMaterialColor()
		
		ingotNode.get_node("AnimatedSprite2D").animation = ingotNode.recipeProperties["name"]
		ingotNode.get_node("Filter").animation = ingotNode.recipeProperties["name"]

		setHeatBars()
		
	else:
		print ("Player already holding ingot")
	
func playerAtCashRegister():
	
	if ingotCheck():
		
		ingotNode = ingotCheck()
		if $AnvilGame.gameCompletedBool:
			var recipeValue = ingotNode.recipeProperties["value"]
			var materialValue = ingotNode.materialProperties["valueMod"]
			var sellValue = 0
			
			if ingotNode.quality == 100:
				sellValue = int(recipeValue*materialValue*4)
			elif ingotNode.quality > 90:
				sellValue = int(recipeValue*materialValue*2)
			else:
				sellValue = int(recipeValue*materialValue*(ingotNode.quality/100))
			
			if kingsSigilActive:
				sellValue = sellValue*2
				kingsSigilActive = false
				
			money += sellValue
			$CashRegister.drawGoldValue(sellValue)
			$CashRegister.play()
			$CashRegister.get_node("Ding").play()
			$GPUParticles2D.amount = sellValue
			$GPUParticles2D.emitting = true
			#$GPUParticles2D.emitting = false
			resetOrder()
			ingotNode.queue_free()

			var query := PhysicsPointQueryParameters2D.new()
			query.collide_with_areas = true
			query.collide_with_bodies = false
			query.position = Vector2(173, 431)
			var space = get_world_2d().direct_space_state
	
			for x in get_world_2d().direct_space_state.intersect_point(query):

				if x.collider.owner.is_in_group("customer"):
					x.collider.owner.ExitShop()
					createCustomer()
					
		else: print("Sorry bar is not complete")
		
	elif activeRecipe == "Awaiting Order" and get_tree().get_nodes_in_group("customer"):
		activeRecipe = recipeBook.keys()[randi_range(0, recipeBook.size()-1)]
		activeMaterial = materialBook.keys()[randi_range(0, materialBook.size()-1)]
		
		if autoMolmol:
			playerAtOreBox()
	
	elif taxManHere:
		money -= snappedf(taxesOwed,1.0)
		$CashRegister.drawGoldValue(-taxesOwed)
		$CashRegister.play()
		$CashRegister.get_node("Ding").play()
		$GPUParticles2D.amount = taxesOwed
		$GPUParticles2D.emitting = true
		taxMan.ExitShop()
		taxManHere = false
		
func playerAtTrashCan():
	if ingotCheck():
		
		ingotNode = ingotCheck()
		$AnvilGame.abortAnvilGame()
		ingotNode.queue_free()
		
#Checks if player is holding an ingot, returns ingot node or false
func ingotCheck():
	for child in $Player.get_children():
		if child.is_in_group("ingot"):
			return child
	return false

func createCustomer():
	var item = load("res://Customer.tscn").instantiate()
	add_child(item)
	item.position = Vector2(172,580)
	item.speed = 100
	
func createTaxMan():
	taxMan = load("res://tax_man.tscn").instantiate()
	add_child(taxMan)
	taxMan.position = Vector2(172,580)
	#taxMan.speed = 1

func _on_anvil_game_game_complete_signal():
	gameFinished = true
	$AnvilGame.hide()

func _input(event):
	if Input.is_action_just_pressed("click"):
		print(event.get_position())

func _on_button_pressed():
	var ingotNode = ingotCheck()
	money += 1*ingotNode.recipeProperties["value"]*ingotNode.materialProperties["valueMod"]*(ingotNode.quality/100)
	resetOrder()
	ingotNode.queue_free()

func _on_ore_box_animation_looped():
	$OreBox.pause()
	
func _on_ore_box_animation_finished(Start):
	$OreBox.pause()

func _on_anvil_game_player_left(child):
		
			remove_child(child)
			$Player.add_child(child)
			print($Player.get_children())
			child.position = Vector2.ZERO

func _on_day_button_pressed():
	resetDay()
	$EndDay.endDay(day, money)

func _on_end_day_next_day_pressed():
	day += 1
	dayTimer = 0.00
	if !taxManHere:
		createCustomer()
	elif taxManHere:
		activeRecipe = "Tax Man is here. Time to Pay up!"
		activeMaterial = "Total Taxes Owed: " + str(snappedf(taxesOwed,1.0))
	
func _on_ready():
	$ThwakToMainMenu.play()
	createCustomer()

func resetDay():
	if $AnvilGame.visible:
		$AnvilGame.abortAnvilGame()
	
	if ingotCheck():
		ingotCheck().queue_free()
		
	var query := PhysicsPointQueryParameters2D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.position = $Forge.position + Vector2(80,100)
	var space = get_world_2d().direct_space_state
	
	for x in get_world_2d().direct_space_state.intersect_point(query):
		if x.collider.owner.is_in_group("ingot"):
			x.collider.owner.queue_free()
			
	for child in get_tree().get_nodes_in_group("customer"):
		child.queue_free()
		
	resetOrder()
	if(day == 1 || day % 5 == 0):
		taxManHere = true
		createTaxMan()

func resetOrder():
	
	activeRecipe = "Awaiting Order"
	activeMaterial = ""
	$"GUI HUD/ProgressBar/IdealHeat".size.y = 0
	$"GUI HUD/ProgressBar/HeatRange".size.y = 0
	
	$AnvilGame.abortAnvilGame()

func setHeatBars():
	
	var idealHeat = $"GUI HUD/ProgressBar/IdealHeat"
	var heatRange = $"GUI HUD/ProgressBar/HeatRange"
	var ingotNode = ingotCheck()
	var idealTemp = ingotNode.materialProperties["idealTemp"]
	var idealTempRange = ingotNode.materialProperties["idealTempRange"]
	
	#Sets top of green ideal temp bar
	if idealTemp + idealTempRange > ingotNode.maxTemp:
		idealHeat.position.y = 0
	else: 
		idealHeat.position.y = $"GUI HUD/ProgressBar".size.y - ((idealTemp + idealTempRange)/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y

	#Sets size (downwards) of ideal temp bar
	if idealTemp - idealTempRange < 0:
		idealHeat.size.y = $"GUI HUD/ProgressBar".size.y - idealHeat.position.y
	elif idealTemp + idealTempRange > ingotNode.maxTemp:
		idealHeat.size.y = (((idealTempRange*2) - ((idealTemp + idealTempRange) - ingotNode.maxTemp)) /ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
	else:
		idealHeat.size.y = ((idealTempRange*2)/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
		
	if idealTemp + idealTempRange + 1000 > ingotNode.maxTemp:
		heatRange.position.y = 0
		
	else: 
		heatRange.position.y = $"GUI HUD/ProgressBar".size.y - ((idealTemp + idealTempRange + 1000 )/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
		
	if idealTemp - idealTempRange - 1000 < 0:
		heatRange.size.y = $"GUI HUD/ProgressBar".size.y - heatRange.position.y
	elif idealTemp + idealTempRange + 1000 > ingotNode.maxTemp:
		heatRange.size.y = ((((idealTempRange+1000)*2) - ((idealTemp + idealTempRange+1000) - ingotNode.maxTemp)) /ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y
	else:
		heatRange.size.y = (((idealTempRange+1000)*2)/ingotNode.maxTemp)*$"GUI HUD/ProgressBar".size.y

func _on_end_day_cooling_dec():
	if money >= coolingModCost[coolingModInc]:
		money -= coolingModCost[coolingModInc]
		coolingModInc += 1
		coolingMod += .09
	else:
		money -= coolingModCost[coolingModInc]
		coolingModInc += 1
		coolingMod += .09
		print("cant afford, but you're cool ;)")

func _on_end_day_heat_inc():
	if money >= heatingModCost[heatingModInc]:
		money -= heatingModCost[heatingModInc]
		heatingModInc += 1
		heatingMod += 5
	else:
		money -= heatingModCost[heatingModInc]
		heatingModInc += 1
		heatingMod += 5
		print("cant afford, but you're cool ;)")

func _on_end_day_speed_inc():
	if money >= playerSpeedModCost[playerSpeedModInc]:
		money -= playerSpeedModCost[playerSpeedModInc]
		playerSpeedModInc += 1
		$Player.increaseSpeed(20)
		 
	else:
		money -= playerSpeedModCost[playerSpeedModInc]
		playerSpeedModInc += 1
		$Player.increaseSpeed(20)
		print("cant afford, but you're cool ;)")

func _on_golden_hammer_pressed():
	goldenHammerActive = true
	goldenHammer = false

func _on_kings_sigil_pressed():
	kingsSigilActive = true
	kingsSigil = false

func _on_be_back_in_5_pressed():
	beBackIn5Active = true
	beBackIn5 = false

func _on_bottled_fire_pressed():
	bottledFire = false
	if ingotCheck():
		ingotCheck().bottledFire(3)
		
	else:
		for child in $AnvilGame.get_children():
			if child.is_in_group("ingot"):
				child.bottledFire(3)
		
