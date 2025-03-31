class_name RefineryShipModule
extends ShipModule

var plate:= Big.ZERO()
var liquid_fuel:= Big.ZERO()
var hydrogen:= Big.ZERO()
var electronic:= Big.ZERO()
var mana:= Big.ZERO()

var plate_refining_duration: float
var plate_refining_input_titanium: Big
var plate_refining_output_efficiency: float

var liquid_fuel_refining_duration: float
var liquid_fuel_refining_input_carbon: Big
var liquid_fuel_refining_output_efficiency: float

var hydrogen_refining_duration: float
var hydrogen_refining_input_water: Big
var hydrogen_refining_output_efficiency: float

var electronic_refining_duration: float
var electronic_refining_input_palladium: Big
var electronic_refining_output_efficiency: float

var mana_refining_duration: float
var mana_refining_input_pyralium: Big
var mana_refining_output_efficiency: float
