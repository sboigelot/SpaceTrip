extends MarginContainer

class_name ShopItemViewBase

var ship: Ship
var data: ShipUpgrade

@export var ui_pin_check_box: CheckBox
@export var ui_buy_button: Button

@export var ui_panel_titanium: PanelContainer
@export var ui_label_titanium: Label
@export var ui_panel_plate: PanelContainer
@export var ui_label_plate: Label
@export var ui_panel_carbon: PanelContainer
@export var ui_label_carbon: Label
@export var ui_panel_liquid_fuel: PanelContainer
@export var ui_label_liquid_fuel: Label
@export var ui_panel_water: PanelContainer
@export var ui_label_water: Label
@export var ui_panel_hydrogen: PanelContainer
@export var ui_label_hydrogen: Label
@export var ui_panel_palladium: PanelContainer
@export var ui_label_palladium: Label
@export var ui_panel_electronic: PanelContainer
@export var ui_label_electronic: Label
@export var ui_panel_pyralium: PanelContainer
@export var ui_label_pyralium: Label
@export var ui_panel_mana: PanelContainer
@export var ui_label_mana: Label

var _only_visible_if_pinned: bool = false
var only_visible_if_pinned: bool:
	get():
		return _only_visible_if_pinned
	set(value):
		_only_visible_if_pinned = value
		check_availability(true)

var pinned: bool:
	get():
		return ui_pin_check_box.button_pressed

func _ready() -> void:
	ui_buy_button.pressed.connect(on_buy)
	ship.new_purchase_done.connect(on_new_ship_purchase_done)
	ship.new_mission_completed.connect(on_new_mission_completed)
	check_availability(true)
	first_update_ui()
	update_ui()
	
func first_update_ui():
	assert(ship != null)
	assert(data != null)
	
	ui_buy_button.text = data.display_name

	update_resouce_cost(data.titanium_cost, 	ship.mining.titanium,		ui_panel_titanium,		ui_label_titanium)
	update_resouce_cost(data.plate_cost,		ship.refinery.plate,		ui_panel_plate,			ui_label_plate)
	update_resouce_cost(data.carbon_cost,		ship.mining.carbon,			ui_panel_carbon,		ui_label_carbon)
	update_resouce_cost(data.liquid_fuel_cost,	ship.refinery.liquid_fuel,	ui_panel_liquid_fuel, 	ui_label_liquid_fuel)
	update_resouce_cost(data.water_cost,		ship.mining.water,			ui_panel_water,			ui_label_water)
	update_resouce_cost(data.hydrogen_cost,		ship.refinery.hydrogen,		ui_panel_hydrogen,		ui_label_hydrogen)
	update_resouce_cost(data.palladium_cost,	ship.mining.palladium,		ui_panel_palladium,		ui_label_palladium)
	update_resouce_cost(data.electronic_cost,	ship.refinery.electronic,	ui_panel_electronic,	ui_label_electronic)
	update_resouce_cost(data.pyralium_cost,		ship.mining.pyralium,		ui_panel_pyralium,		ui_label_pyralium)
	update_resouce_cost(data.mana_cost,			ship.refinery.mana,		ui_panel_mana,			ui_label_mana)

func update_resouce_cost(cost: Big, stock:Big, ui_panel: PanelContainer, ui_label: Label):
	if cost == null or cost.isLessThanOrEqualTo(0.0):
		ui_panel.visible = false
	else:
		ui_panel.visible = true
		ui_label.text = cost.toMetricSymbol(true, true)
		var stock_available = stock.isGreaterThanOrEqualTo(cost)
		ui_label.modulate = Color.GRAY if stock_available else Color.WHITE 
	
func on_new_ship_purchase_done(purchase_name):
	check_availability(false)
	
func on_new_mission_completed(purchase_name):
	check_availability(false)

func check_availability(force_check:bool):
	if not force_check and visible:
		return
		
	if data.debug_hook:
		pass
		
	for parent_missions in data.parent_missions:
		if not ship.mission_completed.has(parent_missions):
			visible = false
			return
			
	for parent_purchase in data.parent_purchases:
		if not ship.purchased_items.has(parent_purchase):
			visible = false
			return
			
	if data.debug_hook:
		pass
		
	if only_visible_if_pinned:
		visible = pinned
	else:
		visible = true
	
func _process(delta: float) -> void:
	
	if ship.dev_tweak_mode  and Input.is_action_just_pressed("refresh_shop"):
		check_availability(true)
		
	if ship.dev_tweak_mode or Input.is_action_just_pressed("refresh_shop"):
		first_update_ui()
		
	update_ui()
	
func update_ui() -> void:
	assert(ship != null)
	assert(data != null)
	
	if not visible:
		return
	
	if ship.god_mode or data.is_free:
		ui_buy_button.disabled = false
	else:
		ui_buy_button.disabled = (
			(data.titanium_cost != null 	and ship.mining.titanium.isLessThan(data.titanium_cost)) or
			(data.plate_cost != null 		and ship.refinery.plate.isLessThan(data.plate_cost)) or
			(data.carbon_cost != null 		and ship.mining.carbon.isLessThan(data.carbon_cost)) or
			(data.liquid_fuel_cost != null 	and ship.refinery.liquid_fuel.isLessThan(data.liquid_fuel_cost)) or
			(data.water_cost != null 		and ship.mining.water.isLessThan(data.water_cost)) or
			(data.hydrogen_cost != null 	and ship.refinery.hydrogen.isLessThan(data.hydrogen_cost)) or
			(data.palladium_cost != null 	and ship.mining.palladium.isLessThan(data.palladium_cost)) or
			(data.electronic_cost != null 	and ship.refinery.electronic.isLessThan(data.electronic_cost)) or
			(data.pyralium_cost != null 	and ship.mining.pyralium.isLessThan(data.pyralium_cost)) or
			(data.mana_cost != null 		and ship.refinery.mana.isLessThan(data.mana_cost))
		)

func on_buy() -> void:
	assert(ship != null)
	assert(data != null)
	queue_free()
	ship.purchase_shop_item(data)
	ship.ui_tooltip.close()
	
func _on_mouse_entered() -> void:
	var tooltip_content = data.get_tooltip_content()
	ship.ui_tooltip.open_and_move(tooltip_content, global_position, true)

func _on_mouse_exited() -> void:
	ship.ui_tooltip.close()
