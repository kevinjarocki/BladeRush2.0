extends Control
@export var clickTarget: PackedScene
var missDistance = 10000000
var missDistanceVector = Vector2()
var userClick = Vector2(-100000,100000)
var nextClick = InstancePlaceholder
var ingotInstance = InstancePlaceholder
var gameCompletedBool = false
var recipeTool = false
var tempRecipeArray = []
var instanceCounter = 0
var instanceBudget = 1
var mouseLocation = Vector2.ZERO
var scaleValue = Vector2(5,5)
@export var ingotPosition = Vector2(500,-500)
var gameStarted = false
var tempQualityMod = 0
var tempMiss = 0
var ingotSprite = AnimatedSprite2D
var ingotFilter = AnimatedSprite2D
var ingotIsChild = false
signal gameCompleteSignal
signal playerLeft(child)

# Called when the node enters the scene tree for the first time.
func _ready():
	ingotPosition = $AnvilTop.position + $AnvilTop.offset
	hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if (event is InputEventMouseButton and visible and Input.is_action_just_pressed("click") and not gameCompletedBool and event.position.y < 570):
		$AnimatedSprite2D.play()
		$Ping.play()
		$AnvilTop.play()
		userClick = event.position
		missDistanceVector = userClick - nextClick.position
		missDistance = missDistanceVector.length()
		#if too hot
		if ingotInstance.temperature > ingotInstance.materialProperties["idealTemp"] + ingotInstance.materialProperties["idealTempRange"]:
			tempMiss = (ingotInstance.temperature - (ingotInstance.materialProperties["idealTemp"] + ingotInstance.materialProperties["idealTempRange"]))
			TempQualitySubtract()
			#if too cold
		elif ingotInstance.temperature < ingotInstance.materialProperties["idealTemp"] - ingotInstance.materialProperties["idealTempRange"]:
			tempMiss = (ingotInstance.materialProperties["idealTemp"] - ingotInstance.materialProperties["idealTempRange"]) - ingotInstance.temperature
			TempQualitySubtract()
		
		#distance punishment
		if owner.goldenHammerActive:
			owner.goldenHammerActive = false
			ingotInstance.stage += 1
			$Perfect.play()
			$GPUParticles2D.position = userClick
			$GPUParticles2D.emitting = true
		elif missDistance <= ingotInstance.recipeProperties["perfectRange"]:
			$Perfect.play()
			$GPUParticles2D.position = userClick
			$GPUParticles2D.emitting = true
		else:
			if missDistance*ingotInstance.recipeProperties["punishRate"] > ingotInstance.quality:
				ingotInstance.quality = 0
				ingotSprite.frame = 2
				ingotFilter.frame = 2
				#qualityHistory.append(ingotInstance.quality)
			else:
				ingotInstance.quality -= missDistance * ingotInstance.recipeProperties["punishRate"]
		print("quality score" ,ingotInstance.quality)
		#WHY IS THIS HERE??? Is this a duplicate of below?? it is apperently needed to index click position
		ingotInstance.stage += 1
		if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):
			nextClick.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
			
		else:
			ingotSprite.frame = 3
			ingotFilter.frame = 3
			#qualityHistory.append(ingotInstance.quality)
			nextClick.killInstance()
			gameCompletedBool = true
			gameCompleteSignal.emit(ingotInstance)
			ingotInstance.isCompleted = true
		if ingotSprite.frame == 2 or ingotFilter.frame ==2:
			nextClick.killInstance()
			gameCompletedBool = true
			#gameCompleteSignal.emit(ingotInstance)
			
	if (event is InputEventMouseMotion and visible):
		$AnimatedSprite2D.position = event.position
		
func summonMinigame(instance):
	ingotInstance = instance
	ingotSprite = ingotInstance.get_node("AnimatedSprite2D")
	ingotFilter = ingotInstance.get_node("Filter")
	ingotSprite.frame = 1
	ingotFilter.frame = 1
	gameStarted = true
	ingotInstance.position = ingotPosition
	ingotInstance.scale = scaleValue
	#This will change the ingot animation to the recipe animation we need. Every animation for evcery weapon type will be a part of the ingot scene
	#ingotInstance.AnimatedSprite2D.animation = ingotInstance.recipe.name

	if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):

		gameCompletedBool = false
		show()
		if instanceBudget > 0:
			nextClick = clickTarget.instantiate()
			nextClick.play()
			instanceCounter += 1
			instanceBudget -= 1
		nextClick.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
		add_child(nextClick)
		move_child(nextClick, 2)
	else:
		ingotSprite.frame = 3
		ingotFilter.frame = 3
		#qualityHistory.append(ingotInstance.quality)
		abortAnvilGame()
		

	#await get_tree().create_timer(1.0).timeout
	
func _on_button_pressed():
	recipeTool = true
func TempQualitySubtract():
	if abs(tempMiss) > 1000:
		ingotInstance.quality = 0
		$Broken.play()
		ingotSprite.frame = 2
		ingotFilter.frame = 2
		#qualityHistory.append(ingotInstance.quality)
	elif abs(tempMiss) > 0 and abs(tempMiss) <= 1000:
		tempQualityMod = -0.008*abs(tempMiss)
		ingotInstance.quality += tempQualityMod
		
func _on_player_departed(body):
	if body.owner.name == "Anvil":
		abortAnvilGame()
func pauseAnvilGame():
	if gameStarted and ingotInstance != null:
		ingotInstance.scale = Vector2(1.5,1.5)
		remove_child(ingotInstance)
		owner.add_child(ingotInstance)
		ingotInstance.position = Vector2(20,10)
		playerLeft.emit(ingotInstance)
		gameCompletedBool = false
	if gameCompletedBool:
		instanceBudget = 1
		gameCompleteSignal.emit(ingotInstance)
		gameStarted = false
		gameCompletedBool = true
	hide()
func abortAnvilGame():
	if !gameCompletedBool and instanceCounter > 0:
		instanceCounter = 0
	if gameStarted and ingotInstance != null:
		ingotInstance.scale = Vector2(1.5,1.5)
		remove_child(ingotInstance)
		owner.add_child(ingotInstance)
		ingotInstance.position = Vector2(20,10)
		playerLeft.emit(ingotInstance)
	if gameCompletedBool:
		instanceBudget = 1
		gameCompleteSignal.emit(ingotInstance)
		gameStarted = false
	#print("quality history array: ",qualityHistory)
	hide()
