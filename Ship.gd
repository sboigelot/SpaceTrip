class_name Ship
extends Node2D

#####################
#		EXPORTS		#
#####################

@export_group("UI elements")
@export var ui_shop_container: Container

@export_group("Ship Modules")
@export var core: CoreShipModule
@export var engine: EngineShipModule
@export var radar: RadarShipModule
@export var mining: MiningShipModule

#####################
#		SIGNALS		#
#####################

signal new_purchase_done(purchase_name)

#####################

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

func _ready() -> void:
	shop_items.assign(ResourceFinder.get_resources_in_folder("res://Data/ShipUpgrades/"))
	
	for shop_item in shop_items:
		var shop_item_view:ShopItemViewBase = shop_item.shop_item_button_view.instantiate()
		shop_item_view.ship = self
		shop_item_view.data = shop_item
		ui_shop_container.add_child(shop_item_view)

func purchase_shop_item(ship_upgrade:ShipUpgrade):
	mining.titanium.minusEquals(ship_upgrade.titanium_cost)
	
	for impact in ship_upgrade.impacts:
		_apply_ship_upgrade_impact(impact)
	
	var dir_str_length = ship_upgrade.resource_path.rfind("/") + 1
	var purchase_name = ship_upgrade.resource_path.substr(
		dir_str_length,
		ship_upgrade.resource_path.length() - dir_str_length - ".tres".length()
	)
	
	purchased_items.append(purchase_name)
	new_purchase_done.emit(purchase_name)
		
func _apply_ship_upgrade_impact(impact:ShipUpgradeImpact):
	
	var module = self
	if impact.ship_module != "":
		module = self[impact.ship_module]
		assert(module != null)
	
	var property = module[impact.property_impacted]
	assert(property != null)
	if property is Big:
		match(impact.impact_method):
			ShipUpgradeImpact.IMPACT_METHOD.ADD:
				property.plusEquals(impact.impact_big)
			ShipUpgradeImpact.IMPACT_METHOD.ADD_PERCENT:
				var percent = property.times(impact.impact_value)
				property.plusEquals(percent)
			ShipUpgradeImpact.IMPACT_METHOD.REMOVE:
				property.minusEquals(impact.impact_big)
			ShipUpgradeImpact.IMPACT_METHOD.REMOVE_PERCENT:
				var percent = property.times(impact.impact_value)
				property.minusEquals(percent)
			ShipUpgradeImpact.IMPACT_METHOD.REPLACE:
				property.replace(impact.impact_big)
	else:
		match(impact.impact_method):
			ShipUpgradeImpact.IMPACT_METHOD.ADD:
				module[impact.property_impacted] += impact.impact_value
			ShipUpgradeImpact.IMPACT_METHOD.ADD_PERCENT:
				var percent = module[impact.property_impacted] * impact.impact_value
				module[impact.property_impacted] += percent
			ShipUpgradeImpact.IMPACT_METHOD.REMOVE:
				module[impact.property_impacted] -= impact.impact_value
			ShipUpgradeImpact.IMPACT_METHOD.REMOVE_PERCENT:
				var percent = module[impact.property_impacted] * impact.impact_value
				module[impact.property_impacted] -= percent
			ShipUpgradeImpact.IMPACT_METHOD.REPLACE:
				module[impact.property_impacted] = impact.impact_value
