extends MarginContainer

class_name ShopItemViewBase

var ship: Ship
var data: ShipUpgrade

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

func _ready() -> void:
	ui_buy_button.pressed.connect(on_buy)
	ship.new_purchase_done.connect(on_new_ship_purchase_done)
	check_availability(true)
	first_update_ui()
	update_ui()
	
func first_update_ui():
	assert(ship != null)
	assert(data != null)
	
	ui_buy_button.text = data.display_name
	
	update_resouce_cost(data.titanium_cost, 	ui_panel_titanium,		ui_label_titanium)
	update_resouce_cost(data.plate_cost,		ui_panel_plate,			ui_label_plate)
	update_resouce_cost(data.carbon_cost,		ui_panel_carbon,		ui_label_carbon)
	update_resouce_cost(data.liquid_fuel_cost,	ui_panel_liquid_fuel, 	ui_label_liquid_fuel)
	update_resouce_cost(data.water_cost,		ui_panel_water,			ui_label_water)
	update_resouce_cost(data.hydrogen_cost,		ui_panel_hydrogen,		ui_label_hydrogen)
	update_resouce_cost(data.palladium_cost,	ui_panel_palladium,		ui_label_palladium)
	update_resouce_cost(data.electronic_cost,	ui_panel_electronic,	ui_label_electronic)
	update_resouce_cost(data.pyralium_cost,		ui_panel_pyralium,		ui_label_pyralium)
	update_resouce_cost(data.mana_cost,			ui_panel_mana,			ui_label_mana)

func update_resouce_cost(cost: Big, ui_panel: PanelContainer, ui_label: Label):
	if cost == null or cost.isLessThanOrEqualTo(0.0):
		ui_panel.queue_free()
	else:
		ui_label.text = cost.toMetricSymbol(true)
	
func on_new_ship_purchase_done(purchase_name):
	check_availability(false)

# can be improved by copying the array on ready and removing the done items 
# on every new purchase
# visible = list empty
func check_availability(force_check:bool):
	if not force_check and visible:
		return
		
	if data.debug_hook:
		pass
		
	for parent_purchase in data.parent_purchases:
		if not ship.purchased_items.has(parent_purchase):
			visible = false
			return
			
	if data.debug_hook:
		pass
		
	visible = true
	
func _process(delta: float) -> void:
	update_ui()
	
func update_ui() -> void:
	assert(ship != null)
	assert(data != null)
	
	if not visible:
		return
		
	ui_buy_button.disabled = (
		(data.titanium_cost == null 	or ship.mining.titanium.isLessThan(data.titanium_cost)) and
		(data.plate_cost == null 		or ship.refinery.plate.isLessThan(data.plate_cost)) and
		(data.carbon_cost == null 		or ship.mining.carbon.isLessThan(data.carbon_cost)) and
		(data.liquid_fuel_cost == null 	or ship.refinery.liquid_fuel.isLessThan(data.liquid_fuel_cost)) and
		(data.water_cost == null 		or ship.mining.water.isLessThan(data.water_cost)) and
		(data.hydrogen_cost == null 	or ship.refinery.hydrogen.isLessThan(data.hydrogen_cost)) and
		(data.palladium_cost == null 	or ship.mining.palladium.isLessThan(data.palladium_cost)) and
		(data.electronic_cost == null 	or ship.refinery.electronic.isLessThan(data.electronic_cost)) and
		(data.pyralium_cost == null 	or ship.mining.pyralium.isLessThan(data.pyralium_cost)) and
		(data.mana_cost == null 		or ship.refinery.mana.isLessThan(data.mana_cost))
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
