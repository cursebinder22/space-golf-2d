class_name Flag
extends Node

var planet: Variant = null
var position: Vector2 = Vector2.ZERO
var angle: float = 0
var lift: float = 0
const form: Array = [
	[[0,0], [4,0], Color(1,1,1)],
	[[4,0], [6,0], 'P'],
	[[6,0], [5,2], 'P'],
	[[5,2], [4,0], 'P'],
]

func _init(init_position: Vector2, init_angle: float = -TAU/4) -> void:
	position = init_position
	angle = init_angle

func get_rotated_form() -> Array:
	var rotated_form: Array = []
	
	for line: Array in form:
		var p1: Vector2 = Vector2(line[0][0], line[0][1])
		var p2: Vector2 = Vector2(line[1][0], line[1][1])
		var color: Variant = line[2]
		
		rotated_form.append([p1.rotated(angle), p2.rotated(angle), color])
		
	return rotated_form

func tick() -> void:
	lift = lerp(lift, 0., Global.lerp_factor)
	
	if planet is Planet:
		angle = lerp_angle(angle, planet.tilt + 20 * planet.tilt_speed, Global.lerp_factor)
		
	elif planet is Ball:
		var pb_angle: float = -TAU/4
		if planet.planet:
			pb_angle = planet.planet.position.angle_to_point(planet.position)
		angle = lerp_angle(angle, pb_angle + cos(Time.get_ticks_msec() * 0.001 * 2) / 4, Global.lerp_factor)
	
	if planet:
		var new_x: float = planet.position.x + (lift + planet.radius) * cos(angle)
		new_x = lerp(position.x, new_x, Global.lerp_factor)
		
		var new_y: float = planet.position.y + (lift + planet.radius) * sin(angle)
		new_y = lerp(position.y, new_y, Global.lerp_factor)
		
		position = Vector2(new_x, new_y)
