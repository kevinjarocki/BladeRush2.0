extends Node2D

@export var money = 0
@export var day = 1
@export var dayTimer = 0.00
@export var endDayTime = 60
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
@export var bottledFire = false
@export var kingsSigil = false
@export var beBackIn5 = false
@export var goldenHammerCost = 10
@export var bottledFireCost = 10
@export var kingsSigilCost = 25
@export var beBackIn5Cost = 50

var taxManHere = false

var ingotNode = null
var gameFinished = false

var recipeBook = {

	"Dagger" : {"points": [Vector2(569, 139),Vector2(628, 191),Vector2(654, 237),Vector2(660, 291),Vector2(660, 293)], 
	"name": "dagger", "perfectRange": 5, "punishRate": 0.2, "value" : 3},
	
	"Scimitar" : {"points": [Vector2(553, 214),Vector2(610, 282),Vector2(515, 326),Vector2(619, 398),Vector2(534, 448)], 
	"name": "scimitar","perfectRange": 3, "punishRate": 0.1, "value" : 5},
	
	"Axe" : {"points": [Vector2(580, 508),Vector2(576, 431),Vector2(578, 365),Vector2(578, 287),Vector2(613, 492),Vector2(614, 440),Vector2(614, 391),Vector2(615, 325),Vector2(550, 266)], 
	"name": "axe", "perfectRange": 10, "punishRate": 0.5, "value" : 8}
}

var materialBook = {
	"Tin" : {"name": "tin", "coolRate" : 10, "heatRate" : 25, "idealTemp": 7500, "idealTempRange": 1200, "valueMod": 1, "cost": 1},
	"Iron" : {"name": "iron", "coolRate" : 8, "heatRate" : 25, "idealTemp": 6600, "idealTempRange": 800, "valueMod": 2, "cost": 1},
	"Bronze" : {"name": "bronze", "coolRate" : 4, "heatRate" : 25, "idealTemp": 4000, "idealTempRange": 1000, "valueMod": 4, "cost": 1},
	"Gold": {"name": "gold", "coolRate" : 20, "heatRate" : 50, "idealTemp": 2000, "idealTempRange": 800, "valueMod": 6, "cost": 1},
	"Rune": {"name": "gold", "coolRate" : 20, "heatRate" : 50, "idealTemp": 2000, "idealTempRange": 800, "valueMod": 6, "cost": 1},
	"Mithril": {"name": "gold", "coolRate" : 20, "heatRate" : 50, "idealTemp": 2000, "idealTempRange": 800, "valueMod": 6, "cost": 1},
	"Caledonite": {"name": "gold", "coolRate" : 20, "heatRate" : 50, "idealTemp": 2000, "idealTempRange": 800, "valueMod": 6, "cost": 1}
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
	if !ingotCheck() and activeRecipe != "Awaiting Order":
		
		$OreBox.play()
		$Ferret.play()
		$Dirt.play()
	
		gameFinished = false
		var ingotNode = load("res://ingot.tscn").instantiate()
		$Player.add_child(ingotNode)
		ingotNode.position = Vector2(20,10)
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
					print(x.collider)
					x.collider.owner.ExitShop()
					createCustomer()
					
		else: print("Sorry bar is not complete")
		
	elif activeRecipe == "Awaiting Order" and get_tree().get_nodes_in_group("customer"):
		activeRecipe = recipeBook.keys()[randi_range(0, recipeBook.size()-1)]
		activeMaterial = materialBook.keys()[randi_range(0, materialBook.size()-1)]
	elif taxManHere:
		activeRecipe = "Tax Man is here. Time to Pay up!"
		activeMaterial = "Total Owed:"
		# totalTax = 10*pwr(day,1.1)
		
		if autoMolmol:
			playerAtOreBox()
		
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
	var taxMan = load("res://tax_man.tscn").instantiate()
	add_child(taxMan)
	taxMan.position = Vector2(172,580)
	#taxMan.speed = 1

func _on_anvil_game_game_complete_signal():
	gameFinished = true
	$AnvilGame.hide()

#func _input(event):
	#if Input.is_action_just_pressed("click"):
		#print(event.get_position())

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
	if(day % 5 == 0):
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
	pass # Replace with function body.

func _on_kings_sigil_pressed():
	pass # Replace with function body.

func _on_be_back_in_5_pressed():
	pass # Replace with function body.

func _on_bottled_fire_pressed():
	pass # Replace with function body.
