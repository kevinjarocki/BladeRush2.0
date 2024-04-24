extends Control
@export var clickTarget: PackedScene
var missDistance = 10000000
var missDistanceVector = Vector2()
var userClick = Vector2(-100000,100000)
var ingotInstance = InstancePlaceholder
var recipeTool = false
var tempRecipeArray = []
var scaleValue = Vector2(5,5)
@export var ingotPosition = Vector2(500,-500)
var tempQualityMod = 0
var tempMiss = 0
var ingotSprite = AnimatedSprite2D
var ingotFilter = AnimatedSprite2D

signal playerLeft(child)

# Called when the node enters the scene tree for the first time.
func _ready():
	ingotPosition = $AnvilTop.position + $AnvilTop.offset
	hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	
	if (visible and Input.is_action_just_pressed("click") and ingotSprite.frame == 1 and event.position.y < 570):
		
		var tempQual = 0
		var posQual = 0
		
		$AnimatedSprite2D.play()
		$Ping.play()
		$AnvilTop.play()
		userClick = event.position
		missDistance = (userClick - $clickTarget.position).length()
		
		#if too hot
		if ingotInstance.temperature > ingotInstance.materialProperties["idealTemp"] + ingotInstance.materialProperties["idealTempRange"]:
			tempMiss = (ingotInstance.temperature - (ingotInstance.materialProperties["idealTemp"] + ingotInstance.materialProperties["idealTempRange"]))
			tempQual = TempQualitySubtract()
		#if too cold
		elif ingotInstance.temperature < ingotInstance.materialProperties["idealTemp"] - ingotInstance.materialProperties["idealTempRange"]:
			tempMiss = (ingotInstance.materialProperties["idealTemp"] - ingotInstance.materialProperties["idealTempRange"]) - ingotInstance.temperature
			tempQual = TempQualitySubtract()
		
		#distance punishment
		if owner.goldenHammerActive:
			owner.goldenHammerActive = false
			ingotInstance.stage += 1
			$Perfect.play()
			$GPUParticles2D.position = userClick
			$GPUParticles2D.emitting = true
			await get_tree().create_timer(.2).timeout
			$Perfect.play()
			
		elif missDistance <= ingotInstance.recipeProperties["perfectRange"]:
			$Perfect.play()
			$GPUParticles2D.position = userClick
			$GPUParticles2D.emitting = true
			
		else:
			posQual = -missDistance * ingotInstance.recipeProperties["punishRate"]
		
		var qualChange = posQual + tempQual
		
		ingotInstance.quality += qualChange
		drawQualityChange(snapped(qualChange, 0.1), event.position)
		
		if ingotInstance.quality  <= 0:
			ingotInstance.quality = 0
			ingotSprite.frame = 2 
			ingotFilter.frame = 2
			$clickTarget.visible = false
			$Broken.play()
			
		else:

			if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):
				ingotInstance.stage += 1
			
			if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()):
				$clickTarget.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
				
			else:
				ingotSprite.frame = 3
				ingotFilter.frame = 3
				$clickTarget.visible = false
				ingotInstance.isCompleted = true
				
		print("quality score" ,ingotInstance.quality)
		
	if (event is InputEventMouseMotion and visible):
		$AnimatedSprite2D.position = event.position
		
func summonMinigame(instance):
	
	$clickTarget.visible = false
	
	for child in self.get_children():
		if child.is_in_group("ingot"):
			ingotInstance = child
			
	ingotSprite = ingotInstance.get_node("AnimatedSprite2D")
	ingotFilter = ingotInstance.get_node("Filter")
	
	if ingotSprite.frame == 0:
		ingotSprite.frame = 1
		ingotFilter.frame = 1
		
	ingotInstance.position = ingotPosition
	ingotInstance.scale = scaleValue
	
	#This will change the ingot animation to the recipe animation we need. Every animation for evcery weapon type will be a part of the ingot scene
	#ingotInstance.AnimatedSprite2D.animation = ingotInstance.recipe.name

	show()
	
	if (ingotInstance.stage < ingotInstance.recipeProperties["points"].size()) and ingotInstance.quality > 0:
		$clickTarget.visible = true
		$clickTarget.position = ingotInstance.recipeProperties["points"][ingotInstance.stage]
		
func TempQualitySubtract():
	if abs(tempMiss) > 1000:
		return (-1000)
		
	elif abs(tempMiss) > 0 and abs(tempMiss) <= 1000:
		return (-0.008*abs(tempMiss))
		
func _on_player_departed(body):
	if body.owner.name == "Anvil":
		abortAnvilGame()
		
func abortAnvilGame():
	ingotInstance = null
	for child in self.get_children():
		if child.is_in_group("ingot"):
			ingotInstance = child
	if ingotInstance:
		ingotInstance.scale = Vector2(1.5,1.5)
		remove_child(ingotInstance)
		owner.add_child(ingotInstance)
		ingotInstance.position = Vector2(20,10)
		playerLeft.emit(ingotInstance)

	hide()
	$clickTarget.visible = false

func drawQualityChange(value, drawPos):
	
	if value == 0:
		$QualityChange.text = "PERFECT"
	else:
		$QualityChange.text = str(value)
		
	$QualityChange.position = drawPos
	$QualityChange.visible = true
	$QualityChange.modulate.a = 1
	
	for x in 30:
		$QualityChange.position.y -= 3
		$QualityChange.modulate.a -= (1.00/30.00)
		await get_tree().create_timer(.03).timeout 
		
	$QualityChange.visible = false
