class_name ShipUpgrade
extends Resource

@export_group("Requirements")
@export var titanium_cost_mantissa: float
@export var titanium_cost_exponent: int
@export var parent_purchases: Array[String]

var _titanium_cost: Big
var titanium_cost: Big:
	get():
		if _titanium_cost == null:
			_titanium_cost = Big.new(titanium_cost_mantissa, titanium_cost_exponent)
		return _titanium_cost
		
@export_group("Impacts")
@export var impacts: Array[ShipUpgradeImpact]

@export_group("Visual")
@export var display_name: String
@export_multiline var lore_descripton: String
@export var shop_item_button_view: PackedScene
