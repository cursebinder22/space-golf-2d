class_name Planet
extends Node

var position: Vector2 = Vector2.ZERO
var speed: float = 0.0
var direction: Vector2 = Vector2.RIGHT.rotated(randf_range(0, TAU))
var radius: float = 0.0
var radius_speed: float = [-1,1].pick_random() * .01
var element: Global.Element = Global.Element.NONE
var tilt: float = TAU * randf()
var tilt_speed: float = randf_range(-1,1) * .01

func _init(init_position: Vector2, init_speed: float, init_radius: float, init_element: Global.Element) -> void:
	position = init_position
	speed = init_speed
	radius = init_radius
	element = init_element

func tick() -> void:
	tilt = fmod(tilt + tilt_speed, TAU)
	
	radius += radius_speed
	if radius <= Global.min_planet_radius:
		radius = Global.min_planet_radius
		radius_speed = abs(radius_speed)
	elif radius >= Global.max_planet_radius:
		radius = Global.max_planet_radius
		radius_speed = -abs(radius_speed)

## Drift, slide, and bounce.
func move() -> void:
		position += Global.drift_speed * direction
		for other_planet: Planet in Global.planets:
			var pp_dist: float = position.distance_to(other_planet.position)
			var min_pp_dist: float = radius + other_planet.radius + Global.init_ball_radius * 2 + 1
			
			if other_planet != self and pp_dist < min_pp_dist:
				position = other_planet.position + min_pp_dist * other_planet.position.direction_to(position)
				direction = other_planet.position.direction_to(position)
				
				other_planet.position = position + min_pp_dist * position.direction_to(other_planet.position)
				other_planet.direction = position.direction_to(other_planet.position)
			
		if position.x < radius + 2 * Global.init_ball_radius + 1:
			direction.x = abs(direction.x)
			position.x = radius + 2 * Global.init_ball_radius + 1
		elif position.x > Global.game_width - radius - 2 * Global.init_ball_radius - 1:
			direction.x *= -abs(direction.x)
			position.x = Global.game_width - radius - 2 * Global.init_ball_radius - 1
		
		#if position.y < radius + Global.default_text_height * 2:
			#direction.y = abs(direction.y)
			#position.y = radius + Global.default_text_height * 2
		if position.y < radius + 2 * Global.init_ball_radius + 1:
			direction.y = abs(direction.y)
			position.y = radius + 2 * Global.init_ball_radius + 1
		elif position.y > Global.game_height - radius - 2 * Global.init_ball_radius - 1:
			direction.y = -abs(direction.y)
			position.y = Global.game_height - radius - 2 * Global.init_ball_radius - 1
