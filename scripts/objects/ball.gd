class_name Ball
extends Node

var position: Vector2 = Vector2.ZERO
var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO
var radius: float = Global.init_ball_radius
var planet: Planet = null
var color: Color = Color(1,1,1)
var power: float:
	get:
		return color.a * color.s # colorful = powerful

func _init(init_position: Vector2) -> void:
	position = init_position

func move() -> void:
	# basic movement
	position += speed * direction
	if planet != null:
		# prevent ball from sliding behind planet motion
		position += Global.drift_speed * planet.direction

	# screen edge impact and bounce
	var impact = false
	if position.x < radius:
		position.x = radius
		direction.x = abs(direction.x)
		impact = true
	elif position.x > Global.game_width - radius:
		position.x = Global.game_width - radius
		direction.x = -abs(direction.x)
		impact = true
	
	if position.y < radius:
		position.y = radius
		direction.y = abs(direction.y)
		impact = true
	elif position.y > Global.game_height - radius:
		position.y = Global.game_height - radius
		direction.y *= -abs(direction.y)
		impact = true
		
	if impact:
		speed *= .5
		color.a = 0
		Global.line_width = clamp(Global.line_width * .5, 0, Global.max_line_width)
		Global.par -= 1
		planet = null
	
	# magnetic rolling around planet
	if planet != null:
		var planet_to_ball_dir: Vector2 = (position - planet.position).normalized()
		var min_dist: float = radius + planet.radius
		var tangent: Vector2 = Vector2.from_angle(planet_to_ball_dir.angle() + TAU/4)
		
		position = planet.position + min_dist * planet_to_ball_dir
		speed *= (1 - Global.friction) * direction.dot(tangent)
		direction = tangent
