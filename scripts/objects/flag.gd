class_name Flag
extends Node2D

var planet: Planet = null
var angle: float = TAU * randf()
var base: Vector2 = Vector2.ZERO
const form: Array = [
	[[0,0], [0,-4], Color(1,1,1)],
	[[0,-4], [0,-6], Color.TRANSPARENT],
	[[0,-6], [2,-5], Color.TRANSPARENT],
	[[2,-5], [0,-4], Color.TRANSPARENT],
]

func rotate_form() -> Array:
	var rotated_form: Array = []
	
	var cos_a: float = cos(angle + TAU/4)
	var sin_a: float = sin(angle + TAU/4)
	
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

func update_base() -> void:
	if planet != null:
		var base_x: float = planet.position.x + planet.radius * cos(angle)
		var base_y: float = planet.position.y + planet.radius * sin(angle)
		base = Vector2(base_x, base_y)
