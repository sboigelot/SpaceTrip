class_name PinCheckBox
extends  CheckBox

var mouse_over: bool

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	toggled.connect(_on_toggled)
	update_ui()
	
func _on_mouse_entered():
	mouse_over = true
	update_ui()
	
func _on_mouse_exited():
	mouse_over = false
	update_ui()
	
func _on_toggled(value:bool):
	update_ui()
	
func update_ui():
	var pin_visible = button_pressed or mouse_over
	modulate.a = 1.0 if pin_visible else 0.0
	
