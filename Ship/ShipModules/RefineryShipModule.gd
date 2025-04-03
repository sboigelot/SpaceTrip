class_name RefineryShipModule
extends ShipModule

var active_refining_output: Big

var plate:= Big.ZERO()
var liquid_fuel:= Big.ZERO()
var hydrogen:= Big.ZERO()
var electronic:= Big.ZERO()
var mana:= Big.ZERO()

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
		"plate*",
		"liquid_fuel*",
		"hydrogen*",
		"electronic*",
		"mana*",
	]
	
func _on_loaded():
	pass
	
func update_stats(delta: float) -> void:
	
	plate_refining_progress = refine_resource(
		ship.mining.titanium, plate,
		plate_refining_duration,
		plate_refining_progress,
		plate_refining_input_titanium,
		plate_refining_output_efficiency,
		plate_refining_active_factor,
		plate_refining_passive_factor,
		delta)
	
	liquid_fuel_refining_progress = refine_resource(
		ship.mining.carbon, liquid_fuel,
		liquid_fuel_refining_duration,
		liquid_fuel_refining_progress,
		liquid_fuel_refining_input_carbon,
		liquid_fuel_refining_output_efficiency,
		liquid_fuel_refining_active_factor,
		liquid_fuel_refining_passive_factor,
		delta)
	
	hydrogen_refining_progress = refine_resource(
		ship.mining.water, hydrogen,
		hydrogen_refining_duration,
		hydrogen_refining_progress,
		hydrogen_refining_input_water,
		hydrogen_refining_output_efficiency,
		hydrogen_refining_active_factor,
		hydrogen_refining_passive_factor,
		delta)
	
	electronic_refining_progress = refine_resource(
		ship.mining.palladium, electronic,
		electronic_refining_duration,
		electronic_refining_progress,
		electronic_refining_input_palladium,
		electronic_refining_output_efficiency,
		electronic_refining_active_factor,
		electronic_refining_passive_factor,
		delta)
	
	mana_refining_progress = refine_resource(
		ship.mining.pyralium, mana,
		mana_refining_duration,
		mana_refining_progress,
		mana_refining_input_pyralium,
		mana_refining_output_efficiency,
		mana_refining_active_factor,
		mana_refining_passive_factor,
		delta)
				
func refine_resource(input: Big, output: Big,
					refining_duration: float,
					refining_progress: float,
					refining_input_count: Big,
					refining_output_efficiency: float,
					refining_active_factor: float,
					refining_passive_factor: float,
					delta: float) -> float:
	
	if refining_duration <= 0.0:
		return refining_progress
	
	if input.isLessThan(refining_input_count):
		return refining_progress
	
	var active = active_refining_output == output
	
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
