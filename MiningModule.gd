class_name MiningShipModule
extends ShipModule

@export_group("UI elements")
@export var ui_ore_label: Label

var ore := Big.ZERO()
var ore_per_asteroid_click := Big.ONE()
var auto_catch_asteroid_chance := 0.0

func update_stats(delta: float) -> void:
	pass
	#ore.plusEquals(Big.multiply(auto_catch_asteroids, delta)) 
	
func update_ui():
	ui_ore_label.text = "Ore: %s" % ore.toMetricSymbol(true)
	
func _on_asteroid_button_pressed() -> void:
	#scrap.plusEquals(scrap_per_asteroid_click)
	ore.plusEquals(ore_per_asteroid_click)
	
