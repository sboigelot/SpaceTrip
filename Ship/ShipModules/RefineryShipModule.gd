class_name RefineryShipModule
extends ShipModule

var active_refining: String

var plate:= Big.ZERO()
var liquid_fuel:= Big.ZERO()
var hydrogen:= Big.ZERO()
var electronic:= Big.ZERO()
var mana:= Big.ZERO()

var global_refinery_speed_factor: float = 1.0

var plate_refining_duration: float = 0.0
var plate_refining_progress: float
var plate_refining_input_titanium: Big = Big.ZERO()
var plate_refining_output_efficiency: float = 0.1
var plate_refining_active_factor: float = 1.0
var plate_refining_passive_factor: float = 0.0

var liquid_fuel_refining_duration: float
var liquid_fuel_refining_progress: float
var liquid_fuel_refining_input_carbon: Big = Big.ZERO()
var liquid_fuel_refining_output_efficiency: float = 0.1
var liquid_fuel_refining_active_factor: float = 1.0
var liquid_fuel_refining_passive_factor: float = 0.0

var hydrogen_refining_duration: float
var hydrogen_refining_progress: float
var hydrogen_refining_input_water: Big = Big.ZERO()
var hydrogen_refining_output_efficiency: float = 0.1
var hydrogen_refining_active_factor: float = 1.0
var hydrogen_refining_passive_factor: float = 0.0

var electronic_refining_duration: float
var electronic_refining_progress: float
var electronic_refining_input_palladium: Big = Big.ZERO()
var electronic_refining_output_efficiency: float = 0.1
var electronic_refining_active_factor: float = 1.0
var electronic_refining_passive_factor: float = 0.0

var mana_refining_duration: float
var mana_refining_progress: float
var mana_refining_input_pyralium: Big = Big.ZERO()
var mana_refining_output_efficiency: float
var mana_refining_active_factor: float = 1.0
var mana_refining_passive_factor: float = 0.0

func get_savable_properties() -> Array[String]:
	return [
		"global_refinery_speed_factor",
		"active_refining",
		"plate*",
		"liquid_fuel*",
		"hydrogen*",
		"electronic*",
		"mana*",
	]
	
func _on_loaded():
	pass
	
func update_stats(delta: float) -> void:
	var refining_delta = global_refinery_speed_factor * delta
	plate_refining_progress = refine_resource("titanium", "plate", refining_delta)
	liquid_fuel_refining_progress = refine_resource("carbon", "liquid_fuel", refining_delta)
	hydrogen_refining_progress = refine_resource("water", "hydrogen", refining_delta)
	electronic_refining_progress = refine_resource("palladium", "electronic", refining_delta)
	mana_refining_progress = refine_resource("pyralium", "mana", refining_delta)
				
func refine_resource(input_resource_name: String, output_resource_name: String, delta: float) -> float:
						
	var input: Big = ship.mining[input_resource_name]
	var output: Big = self[output_resource_name]
	var refining_duration = self[output_resource_name + "_refining_duration"]
	var refining_progress = self[output_resource_name + "_refining_progress"]
	var refining_input_count = self[output_resource_name + "_refining_input_" + input_resource_name]
	var refining_output_efficiency = self[output_resource_name + "_refining_output_efficiency"]
	var refining_active_factor = self[output_resource_name + "_refining_active_factor"]
	var refining_passive_factor = self[output_resource_name + "_refining_passive_factor"]
	
	if refining_duration <= 0.0:
		return refining_progress
	
	if input.isLessThan(refining_input_count):
		return refining_progress
	
	var active = active_refining == output_resource_name
	
	refining_progress += delta * refining_passive_factor
	if active:
		refining_progress += delta * refining_active_factor
	
	while refining_progress >= refining_duration:
		refining_progress -= refining_duration
		input.minusEquals(refining_input_count)
		output.plusEquals(refining_input_count.times(refining_output_efficiency))
	
	return refining_progress
		

func update_ui():
	pass
