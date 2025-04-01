class_name Ship
extends Node2D

#####################
#		EXPORTS		#
#####################

@export_group("Debug")

@export var god_mode: bool = false

@export_group("UI elements")
@export var ui_mission_container: Container
@export var ui_mission_reward_hud: RewardHUD
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
@export var ui_shop_container_no_upgrade_title: Label

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
signal new_mission_completed(mission_name)

#####################

var shop_items: Array[ShipUpgrade]
var purchased_items: Array[String]

var missions: Array[Mission]
var mission_completed: Array[String]

func _ready() -> void:
	load_missions()
	load_shop()
	check_shop_dependencies()
	check_mission_dependencies()
	update_ui()

func load_missions():
	missions.assign(ResourceFinder.get_resources_in_folder("res://Data/Missions/", ".tres", true))
	
	for mission in missions:
		var mission_view:MissionView = mission.mission_view.instantiate()
		mission_view.ship = self
		mission_view.data = mission
		mission_view.ui_mission_reward_hud = ui_mission_reward_hud
		ui_mission_container.add_child(mission_view)
	
func load_shop():
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

func shop_item_exist(display_name: String)-> bool:
	var found = false
	for shop_item in shop_items:
		if shop_item.display_name == display_name:
			found = true
			break
	return found
	
func mission_exist(display_name: String)-> bool:
	var found = false
	for mission in missions:
		if mission.display_name == display_name:
			found = true
			break
	return found
	
func check_shop_dependencies():
	for shop_item in shop_items:
		for parent_shop_item in shop_item.parent_purchases:
			if not shop_item_exist(parent_shop_item):
				printerr("In shop item '%s', parent purchase not found: '%s'" % [
					shop_item.display_name,
					parent_shop_item
				])
		for parent_mission in shop_item.parent_missions:
			if not mission_exist(parent_mission):
				printerr("In shop item '%s', parent mission not found: '%s'" % [
					shop_item.display_name,
					parent_mission
				])

func check_mission_dependencies():
	for mission in missions:
		for parent_shop_item in mission.parent_purchases:
			if not shop_item_exist(parent_shop_item):
				printerr("In mission '%s', parent purchase not found: '%s'" % [
					mission.display_name,
					parent_shop_item
				])
		for parent_mission in mission.parent_missions:
			if not mission_exist(parent_mission):
				printerr("In mission '%s', parent mission not found: '%s'" % [
					mission.display_name,
					parent_mission
				])

func update_ui():
	ui_shop_container_core_title.visible = 		any_child_visible(ui_shop_container_core)
	ui_shop_container_engine_title.visible = 	any_child_visible(ui_shop_container_engine)
	ui_shop_container_radar_title.visible = 	any_child_visible(ui_shop_container_radar)
	ui_shop_container_mining_title.visible =	any_child_visible(ui_shop_container_mining)
	ui_shop_container_refinery_title.visible =	any_child_visible(ui_shop_container_refinery)
	
	ui_shop_container_no_upgrade_title.visible = (
		not ui_shop_container_core_title.visible and
		not ui_shop_container_engine_title.visible and
		not ui_shop_container_radar_title.visible and
		not ui_shop_container_mining_title.visible and
		not ui_shop_container_refinery_title.visible
	)

func any_child_visible(container:Container):
	for child in container.get_children(false):
		if child.visible and not child.is_queued_for_deletion():
			return true
	return false

func pay_for_shop_item(ship_upgrade:ShipUpgrade):
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
	
func purchase_shop_item(ship_upgrade: ShipUpgrade):
	
	if not god_mode:
		pay_for_shop_item(ship_upgrade)
		
	for impact in ship_upgrade.impacts:
		_apply_ship_upgrade_impact(impact)
	
	purchased_items.append(ship_upgrade.display_name)
	new_purchase_done.emit(ship_upgrade.display_name)
	update_ui()
	
func complete_mission(mission: Mission):
	mission_completed.append(mission.display_name)
	new_mission_completed.emit(mission.display_name)
	update_ui()

func get_ship_module(module_name:String):
	var module = self
	if module_name != "":
		module = self[module_name]
		assert(module != null)
	return module
	
func get_ship_property(module_name:String, property_name:String):
	var module = get_ship_module(module_name)
	var property = module[property_name]
	assert(property != null)
	return property
	
func _apply_ship_upgrade_impact(impact:ShipUpgradeImpact):
	
	var property = get_ship_property(impact.ship_module, impact.property_impacted)
	
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
		var module = get_ship_module(impact.ship_module)
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
