class_name Flag
extends Node

var planet: Planet = null
var position: Vector2 = Vector2.ZERO
var angle: float = 0
var lift: float = 0
const form: Array = [
	[[0,0], [4,0], Color(1,1,1)],
	[[4,0], [6,0], Color.TRANSPARENT],
	[[6,0], [5,2], Color.TRANSPARENT],
	[[5,2], [4,0], Color.TRANSPARENT],
]

func get_rotated_form() -> Array:
	var rotated_form: Array = []
	
	var cos_a: float = cos(angle)
	var sin_a: float = -sin(angle)
	
	for line: Array in form:
		var p1: Array = line[0]
		var p2: Array = line[1]
		var color: Color = line[2]
		
		var x1: float = p1[0] * cos_a - p1[1] * sin_a
		var y1: float = p1[0] * sin_a + p1[1] * cos_a
		var x2: float = p2[0] * cos_a - p2[1] * sin_a
		var y2: float = p2[0] * sin_a + p2[1] * cos_a
		
		rotated_form.append([[x1, y1], [x2, y2], color])
		
	return rotated_form

func tick() -> void:
	lift = lerp(lift, 0., Global.lerp_factor)
	angle = lerp_angle(angle, TAU/4 + planet.tilt + 20 * planet.tilt_speed, Global.lerp_factor)
	
	if planet != null:
		var new_x: float = planet.position.x + (lift + planet.radius) * cos(angle)
		new_x = lerp(position.x, new_x, Global.lerp_factor)
		
		var new_y: float = planet.position.y + (lift + planet.radius) * -sin(angle)
		new_y = lerp(position.y, new_y, Global.lerp_factor)
		
		position = Vector2(new_x, new_y)
