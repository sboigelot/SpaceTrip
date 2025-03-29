extends MarginContainer

class_name ShopItemViewBase

var ship: Ship
var data: ShipUpgrade

@export var buy_button: Button

func _ready() -> void:
	buy_button.pressed.connect(on_buy)
	ship.new_purchase_done.connect(on_new_ship_purchase_done)
	check_availability(true)
	update_ui()
	
func on_new_ship_purchase_done(purchase_name):
	check_availability(false)

# can be improved by copying the array on ready and removing the done items 
# on every new purchase
# visible = list empty
func check_availability(force_check:bool):
	if not force_check and visible:
		return
		
	for parent_purchase in data.parent_purchases:
		if not ship.purchased_items.has(parent_purchase):
			visible = false
			return
	visible = true
	
func _process(delta: float) -> void:
	update_ui()
	
func update_ui() -> void:
	assert(ship != null)
	assert(data != null)
	
	if not visible:
		return
	
	buy_button.text = "Increase %s by %s for %s ore" % [
		data.property_to_increase,
		data.increase_value.toMetricSymbol(true),
		data.titanium_cost.toMetricSymbol(true)
	]
	buy_button.disabled = ship.mining.titanium.isLessThan(data.titanium_cost)

func on_buy() -> void:
	assert(ship != null)
	assert(data != null)
	ship.purchase_shop_item(data)
	queue_free()
	
