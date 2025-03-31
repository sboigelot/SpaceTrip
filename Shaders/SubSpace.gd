extends ColorRect
var shader_material: ShaderMaterial

func _ready():
	shader_material = self.material
	
func _process(delta):
	if not visible:
		return
	var mouse_pos = get_local_mouse_position() / 100
	shader_material.set_shader_parameter("mouse_position", mouse_pos)
