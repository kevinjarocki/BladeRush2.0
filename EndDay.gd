extends Node2D

var heatingMod = 0
var moneyPrevTurn = 0
var moneyEarned = 0
var beBackIn5Game = false
var taxesDueDate = 0
var taxesDueValue = 0

signal nextDayPressed
signal speedInc
signal coolingDec
signal heatInc

func _ready():
	$"Control/Golden Hammer/Label".text = str(owner.goldenHammerCost) + " G"
	$"Control/Kings Sigil/Label".text = str(owner.kingsSigilCost)+ " G"
	$"Control/Be Back in 5/Label".text = str(owner.beBackIn5Cost)+ " G"
	$"Control/Bottled Fire/Label".text = str(owner.bottledFireCost)+ " G"
	
func _process(delta):
	$Control/PlayerSpeedInc.text = "Increase Player Walk Speed; \nLevel: " + str(owner.playerSpeedModInc) + "/10 Costs: " + str(owner.playerSpeedModCost[owner.playerSpeedModInc]) + "G"
	$Control/CoolingRateDec.text = "Decrease Cooling Rate; \nLevel: " + str(owner.coolingModInc) + "/10 Costs: " + str(owner.coolingModCost[owner.coolingModInc]) + "G"
	$Control/HeatRateInc.text = "Increase Heating Rate; \nLevel: " + str(owner.heatingModInc) + "/10 Costs: " + str(owner.heatingModCost[owner.heatingModInc]) + "G"
	$Control/Info.text = "Finished Day: " + str(owner.day) + "\nGold Earned: " + str(moneyEarned) + "G\nGold: " + str(owner.money) + "G\nReputation: " + str(floor(owner.rep)) + "\nDays Left Before Taxes Due:" + str(taxesDueDate-1) + " Days\n" + str(taxesDueValue) + " Gs"
	
	$Control/AutoIngot.text = "Auto Molmol: " + str(owner.autoMolmol) + "\nCosts: " + str(owner.autoMolmolCost) + "G"
	
	$"Control/Golden Hammer".disabled = owner.goldenHammer 
	$"Control/Kings Sigil".disabled = owner.kingsSigil
	if beBackIn5Game:
		$"Control/Be Back in 5".disabled = true
	else:
		$"Control/Be Back in 5".disabled = false
	$"Control/Bottled Fire".disabled = owner.bottledFire
	
func endDay(day, money):
	visible = true
	if owner.day == 1:
		taxesDueDate = 1
		taxesDueValue = 2
	else:
		taxesDueDate = 5 - (owner.day % 5)
		taxesDueValue = int(6*pow((((owner.day/5)+1)*5),1.1))
	moneyEarned = owner.money - moneyPrevTurn

func _on_next_day_pressed():
	visible = false
	moneyPrevTurn = owner.money
	nextDayPressed.emit()

func _on_player_speed_inc_pressed():
	if owner.playerSpeedModInc < 10:
		speedInc.emit()

func _on_cooling_rate_dec_pressed():
	if owner.coolingModInc < 10:
		coolingDec.emit()

func _on_heat_rate_inc_pressed():
	if owner.heatingModInc < 10:
		heatInc.emit()

func _on_auto_ingot_pressed():
	if !owner.autoMolmol and owner.money >= owner.autoMolmolCost:
		owner.money -= owner.autoMolmolCost
		owner.autoMolmol = true

func _on_golden_hammer_pressed():
	if owner.money >= owner.goldenHammerCost:
		owner.money -= owner.goldenHammerCost
		owner.goldenHammer = true
	pass # Replace with function body.

func _on_kings_sigil_pressed():
	if owner.money >= owner.kingsSigilCost:
		owner.money -= owner.kingsSigilCost
		owner.kingsSigil = true
	pass # Replace with function body.

func _on_be_back_in_5_pressed():
	if owner.money >= owner.beBackIn5Cost:
		beBackIn5Game = true
		owner.money -= owner.beBackIn5Cost
		owner.beBackIn5 = true
	pass # Replace with function body.

func _on_bottled_fire_pressed():
	if owner.money >= owner.bottledFireCost:
		owner.money -= owner.bottledFireCost
		owner.bottledFire = true
	pass # Replace with function body.
