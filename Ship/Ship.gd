class_name Ship
extends Node2D

#####################
#		EXPORTS		#
#####################

@export_group("UI elements")
@export var ui_shop_container_core_title: Label
@export var ui_shop_container_core: Container
@export var ui_shop_container_engine_title: Label
@export var ui_shop_container_engine: Container
@export var ui_shop_container_radar_title: Label
@export var ui_shop_container_radar: Container
@export var ui_shop_container_mining_title: Label
@export var ui_shop_container_mining: Container
@export var ui_shop_container_refinery_title: Label
@export var ui_shop_container_refinery: Container

@export var ui_tooltip: RichTextTooltip
@export var ui_shop_eye: VisibilityControlCheckBox

@export_group("Ship Modules")
@export var core: CoreShipModule
@export var engine: EngineShipModule
@export var radar: RadarShipModule
@export var mining: MiningShipModule
@export var refinery: RefineryShipModule

#####################
#		SIGNALS		#
#####################

signal new_purchase_done(purchase_name)

#####################

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

func _ready() -> void:
	shop_items.assign(ResourceFinder.get_resources_in_folder("res://Data/ShipUpgrades/", ".tres", true))
	
	for shop_item in shop_items:
		var shop_item_view:ShopItemViewBase = shop_item.shop_item_button_view.instantiate()
		shop_item_view.ship = self
		shop_item_view.data = shop_item
		
		var ui_shop_container = ui_shop_container_core
		match shop_item.impacts[0].ship_module:
			"core":
				ui_shop_container = ui_shop_container_core
			"engine":
				ui_shop_container = ui_shop_container_engine
			"radar":
				ui_shop_container = ui_shop_container_radar
			"mining":
				ui_shop_container = ui_shop_container_mining
			"refinery":
				ui_shop_container = ui_shop_container_refinery
		ui_shop_container.add_child(shop_item_view)
	
	update_ui()

func update_ui():
	ui_shop_container_core_title.visible = 		any_child_visible(ui_shop_container_core)
	ui_shop_container_engine_title.visible = 	any_child_visible(ui_shop_container_engine)
	ui_shop_container_radar_title.visible = 	any_child_visible(ui_shop_container_radar)
	ui_shop_container_mining_title.visible =	any_child_visible(ui_shop_container_mining)
	ui_shop_container_refinery_title.visible =	any_child_visible(ui_shop_container_refinery)

func any_child_visible(container:Container):
	for child in container.get_children(false):
		if child.visible and not child.is_queued_for_deletion():
			return true
	return false
	
func purchase_shop_item(ship_upgrade:ShipUpgrade):
	
	if ship_upgrade.titanium_cost != null:
		mining.titanium.minusEquals(ship_upgrade.titanium_cost)
	if ship_upgrade.plate_cost != null:
		refinery.plate.minusEquals(ship_upgrade.plate_cost)
	
	if ship_upgrade.carbon_cost != null:
		mining.carbon.minusEquals(ship_upgrade.carbon_cost)
	if ship_upgrade.liquid_fuel_cost != null:
		refinery.liquid_fuel.minusEquals(ship_upgrade.liquid_fuel_cost)
	
	if ship_upgrade.water_cost != null:
		mining.water.minusEquals(ship_upgrade.water_cost)
	if ship_upgrade.hydrogen_cost != null:
		refinery.hydrogen.minusEquals(ship_upgrade.hydrogen_cost)
	
	if ship_upgrade.palladium_cost != null:
		mining.palladium.minusEquals(ship_upgrade.palladium_cost)
	if ship_upgrade.electronic_cost != null:
		refinery.electronic.minusEquals(ship_upgrade.electronic_cost)
	
	if ship_upgrade.pyralium_cost != null:
		mining.pyralium.minusEquals(ship_upgrade.pyralium_cost)
	if ship_upgrade.mana_cost != null:
		refinery.mana.minusEquals(ship_upgrade.mana_cost)
	
		
	for impact in ship_upgrade.impacts:
		_apply_ship_upgrade_impact(impact)
	
	purchased_items.append(ship_upgrade.display_name)
	new_purchase_done.emit(ship_upgrade.display_name)
	update_ui()

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
			ShipUpgradeImpact.IMPACT_METHOD.REPLACE_BY:
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
			ShipUpgradeImpact.IMPACT_METHOD.REPLACE_BY:
				module[impact.property_impacted] = impact.impact_value

func _on_shop_eye_check_box_mouse_entered() -> void:
	var tooltip_content = "Show / Hide Upgrades"
	ui_tooltip.open_and_move(tooltip_content, ui_shop_eye.global_position, true)

func _on_shop_eye_check_box_mouse_exited() -> void:
	ui_tooltip.close()
