extends Node2D

@onready var view_size = get_viewport().size
@onready var min_view_size = min(view_size.x, view_size.y)

# friction info
const high_friction = .2
const normal_friction = .1
const low_friction = .01

# planet info
const drift_speed = 1
var planets = []
@onready var line_width = min_view_size / 2**8
@onready var total_planets = Element.size()

# star info
const star_density = 1 / 10000.
const max_star_flux = 1
const max_star_speed = 10
var stars = []
@onready var total_stars = view_size.x * view_size.y * star_density
@onready var min_star_radius = line_width / 2**2
@onready var max_star_radius = line_width

# ball info
@onready var normal_ball_radius = line_width * 2**2
@onready var ball = {
	'position': Vector2(view_size.x / 2, -2 * normal_ball_radius),
	'speed': 0, 
	'direction': Vector2.ZERO,
	'radius': normal_ball_radius,
	'planet': null,
	'color': Color.WHITE
}

# aimer info
var click_start_pos: Vector2
var click_end_pos: Vector2
var click_drag_pos: Vector2
var draw_drag_line = false
var fade_drag_line = false
var line_end_pos: Vector2
var drag_color: Color

# element info
enum Element {EARTH, FIRE, ENERGY, NATURE, AIR, ICE, WATER, MAGIC, LOVE, LIGHT, MIGHT, SIGHT}
@onready var elements = {
	Element.EARTH: {
		'friction': low_friction,
		'row': 0,
		'column': 0,
		'order': 1,
		'color': Color(1,0,0),
		'color_name': 'red',
		'symbol': 'volcano',
		'aspect': 'rage',
		'realm': 'hell',
		'pattern': {
			0: [1],
			1: [2],
			2: [3,'C'],
			3: [4],
			4: [],
			5: [6,7,'C'],
			6: [7,'C'],
			7: ['C'],
			'C': []
		}
	},
	Element.FIRE: {
		'friction': low_friction,
		'row': -1,
		'column': -1,
		'order': 2,
		'color': Color(1,.5,0),
		'color_name': 'orange',
		'symbol': 'torch',
		'aspect': 'fear',
		'realm': 'chaos',
		'pattern': {
			0: [5,7],
			1: [5,7],
			2: [5,7],
			3: [5,7],
			4: [5,7],
			5: [],
			7: []
		}
	},
	Element.ENERGY: {
		'friction': low_friction,
		'row': -1,
		'column': 1,
		'order': 3,
		'color': Color(1,1,0),
		'color_name': 'yellow',
		'symbol': 'spark',
		'aspect': 'thrill',
		'realm': 'power',
		'pattern': {
			0: [4,6],
			1: [5,6],
			2: [4,5],
			4: [],
			5: [],
			6: []
		}
	},
	Element.NATURE: {
		'friction': low_friction,
		'row': -2,
		'column': 0,
		'order': 4,
		'color': Color(0,1,0),
		'color_name': 'green',
		'symbol': 'tree',
		'aspect': 'joy',
		'realm': 'life',
		'pattern': {
			0: [2,4],
			2: [4,5,7],
			4: [],
			5: ['C'],
			6: ['C'],
			7: ['C'],
			'C': []
		}
	},
	Element.AIR: {
		'friction': low_friction,
		'row': -3,
		'column': -1,
		'order': 5,
		'color': Color(0,1,1),
		'color_name': 'cyan',
		'symbol': 'creature',
		'aspect': 'freedom',
		'realm': 'heaven',
		'pattern': {
			0: [4,5],
			1: ['C'],
			3: ['C'],
			4: [7],
			5: ['C'],
			6: ['C'],
			7: ['C'],
			'C': []
		}
	},
	Element.ICE: {
		'friction': low_friction,
		'row': -3,
		'column': 1,
		'order': 6,
		'color': Color(0,.5,1),
		'color_name': 'cerulean',
		'symbol': 'star',
		'aspect': 'peace',
		'realm': 'winter',
		'pattern': {
			1: [3,5],
			2: [5,7],
			3: [7],
			5: [],
			7: []
		}
	},
	Element.WATER: {
		'friction': low_friction,
		'row': -4,
		'column': 0,
		'order': 7,
		'color': Color(0,0,1),
		'color_name': 'cobalt',
		'symbol': 'droplet',
		'aspect': 'sorrow',
		'realm': 'depths',
		'pattern': {
			2: [5,6,7],
			5: [6,7],
			6: [7],
			7: []
		}
	},
	Element.MAGIC: {
		'friction': low_friction,
		'row': -5,
		'column': -1,
		'order': 8,
		'color': Color(.5,0,1),
		'color_name': 'purple',
		'symbol': 'crystal',
		'aspect': 'melancholy',
		'realm': 'secrets',
		'pattern': {
			0: [1,4,6],
			1: [3,'C'],
			3: [4,'C'],
			4: [6,'C'],
			6: ['C'],
			'C': []
		}
	},
	Element.LOVE: {
		'friction': low_friction,
		'row': -5,
		'column': 1,
		'order': 9,
		'color': Color(1,0,1).lightened(.5),
		'color_name': 'pink',
		'symbol': 'heart',
		'aspect': 'safety',
		'realm': 'family',
		'pattern': {
			0: [1,6],
			1: [6,'C'],
			3: [4,6,'C'],
			4: [6],
			6: ['C'],
			'C': []
		}
	},
	Element.LIGHT: {
		'friction': low_friction,
		'row': -6,
		'column': 0,
		'order': 10,
		'color': Color(1,1,1),
		'color_name': 'white',
		'symbol': 'sun',
		'aspect': 'clarity',
		'realm': 'space',
		'pattern': {
			0: [2,6],
			1: [3,7],
			2: [4],
			3: [5],
			4: [6],
			5: [7],
			6: [],
			7: []
		}
	},
	Element.MIGHT: {
		'friction': low_friction,
		'row': -7,
		'column': -1,
		'order': 11,
		'color': Color(.67,.67,.67),
		'color_name': 'gray',
		'symbol': 'moon',
		'aspect': 'presence',
		'realm': 'reality',
		'pattern': {
			0: [1,6,7],
			1: [7],
			3: [4,5],
			4: [5,6],
			5: [6,7],
			6: [7],
			7: []
		}
	},
	Element.SIGHT: {
		'friction': low_friction,
		'row': -7,
		'column': 1,
		'order': 12,
		'color': Color(.33,.33,.33),
		'color_name': 'black',
		'symbol': 'eye',
		'aspect': 'desire',
		'realm': 'spirit',
		'pattern': {
			0: [3,5],
			1: [4],
			2: [6],
			3: [],
			4: [7],
			5: [],
			6: [],
			7: []
		}
	}
}

func order_up(element: Element) -> Element:
	for e in Element.values():
		if elements[element].order + 1 == elements[e].order:
			return e
	return Element.EARTH

func _ready() -> void:
	# nearest neighbor texture scaling
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# generate stars
	for i in range(total_stars):
		stars.append({
			'position': Vector2(randi_range(0, view_size.x - 1), randi_range(0, view_size.y - 1)),
			'speed': randf_range(0, max_star_speed),
			'direction': randf_range(0,TAU),
			'radius': randf_range(min_star_radius, max_star_radius),
			'flux_dir': [-1,1].pick_random()
		})
	
	# generate planets
	for i in range(total_planets):
		var element = Element.values()[i]
		var planet_radius = min_view_size / 2**3
		var planet_x = view_size.x / 2 + elements[element].column * planet_radius * 2
		var planet_y = elements[element].row * view_size.y / 6 - planet_radius - line_width - normal_ball_radius * 2
		planets.append({
			'position': Vector2(planet_x, planet_y),
			'radius': planet_radius,
			'element': element
		})

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_start_pos = event.position
				draw_drag_line = true
				fade_drag_line = false
			else: # release click
				click_end_pos = event.position
				fade_drag_line = true
				ball.direction = (-click_end_pos + click_start_pos).normalized()
				ball.speed = click_end_pos.distance_to(click_start_pos) / 50
				if ball.planet != null:
					ball.color = elements[ball.planet.element].color
				ball.planet = null

func _process(delta: float) -> void:
	# for draw function's drag line
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_drag_pos = get_global_mouse_position()
	
	# basic ball movement (before collision & wrapping)
	ball.position += ball.speed * ball.direction
	ball.position.y += drift_speed # keeps ball from sliding behind planet motion
	
	# planets: drift downward, wrap around screen
	for planet in planets:
		planet.position.y += drift_speed
		if planet.position.y > view_size.y + planet.radius + line_width + 2 * normal_ball_radius:
			planet.position.y -= view_size.y * 8/6
		
		# transfer ownership if ball collision
		var dist = ball.position.distance_to(planet.position)
		var min_dist = ball.radius + planet.radius + line_width
		if dist < min_dist:
			ball.planet = planet
	
	# wrap ball around screen edges
	if ball.position.x < -ball.radius:
		ball.position.x += view_size.x + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	elif ball.position.x > view_size.x + ball.radius:
		ball.position.x -= view_size.x + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	if ball.position.y < -ball.radius:
		ball.position.y += view_size.y + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	elif ball.position.y > view_size.y + ball.radius:
		ball.position.y -= view_size.y + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	
	# planet-magnetized ball rolling behavior
	if ball.planet != null:
		var planet_to_ball_dir = (ball.position - ball.planet.position).normalized()
		var min_dist = ball.radius + ball.planet.radius + line_width/2
		var tangent = Vector2.from_angle(planet_to_ball_dir.angle() + TAU/4)
		ball.position = ball.planet.position + min_dist * planet_to_ball_dir
		ball.speed *= (1 - elements[ball.planet.element].friction) * ball.direction.dot(tangent)
		ball.direction = tangent
	
	# stars randomly wander
	for star in stars:
		var velocity = Vector2(
			star.speed * cos(star.direction),
			star.speed * -sin(star.direction))
		star.position += velocity * delta
		
		# fluxuate radius and direction
		var nudge = star.flux_dir * max_star_flux * (star.speed / max_star_speed) * delta
		star.radius += nudge
		star.direction += nudge
		if star.radius < min_star_radius:
			star.radius = min_star_radius
			star.flux_dir *= -1
		elif star.radius > max_star_radius:
			star.radius = max_star_radius
			star.flux_dir *= -1 
		
		# wrap x
		if star.position.x < 0 - star.radius:
			star.position.x += view_size.x + star.radius * 2
		elif star.position.x >= view_size.x + star.radius:
			star.position.x -= view_size.x + star.radius * 2
		
		# wrap y
		if star.position.y < 0 - star.radius:
			star.position.y += view_size.y + star.radius * 2
		elif star.position.y >= view_size.y + star.radius:
			star.position.y -= view_size.y + star.radius * 2
	
	# call draw function
	queue_redraw()

func draw_pattern(position: Vector2, element: Element, radius: float, color: Color, line_width: float = line_width):
	for from_point in elements[element].pattern:
		for to_point in elements[element].pattern[from_point]:
			var from_point_pos = position + Vector2(
				radius * cos(from_point * TAU/8),
				radius * -sin(from_point * TAU/8)
			)
			if str(to_point) == 'C':
				draw_line(from_point_pos, position, color, line_width, true)
			else:
				var to_point_pos = position + Vector2(
					radius * cos(to_point * TAU/8),
					radius * -sin(to_point * TAU/8)
				)
				draw_line(from_point_pos, to_point_pos, color, line_width, true)

func _draw() -> void:
	for star in stars:
		# lux contingent on radius, affects color
		var lux = (star.radius - min_star_radius) / (max_star_radius - min_star_radius)
		var color = Color(lux, lux, lux)
		draw_circle(star.position, star.radius, color, true, -1.0, true)
	
	for planet in planets:
		var planet_color = elements[planet.element].color
		
		# hide stars behind planet
		draw_circle(planet.position, planet.radius, Color(0,0,0), true)
		
		# smaller corner patterns
		for from_point in elements[planet.element].pattern:
			if str(from_point) == 'C':
				draw_pattern(planet.position, planet.element, planet.radius * 1/3, planet_color.darkened(.5))
			else:
				var from_point_pos = planet.position + Vector2(
					planet.radius * 2/3 * cos(from_point * TAU/8),
					planet.radius * 2/3 * -sin(from_point * TAU/8)
				)
				draw_pattern(from_point_pos, planet.element, planet.radius * 1/3, planet_color.darkened(.5))
		
		# largest central pattern
		draw_pattern(planet.position, planet.element, planet.radius * 2/3, planet_color)
		
		# planet surface rim
		draw_circle(planet.position, planet.radius, planet_color, false, line_width, true)
	
	# drag line and dots
	if draw_drag_line:
		var dist = click_start_pos.distance_to(click_drag_pos)
		var ratio = clamp(dist / min_view_size, 0, 1)
		if not fade_drag_line:
			line_end_pos = ball.position - (click_drag_pos - click_start_pos) / 4
			drag_color = Color.from_hsv(ratio, 1, 1)
		else:
			drag_color.a -= .1
			if drag_color.a <= 0:
				draw_drag_line = false
		draw_line(ball.position, line_end_pos, drag_color, line_width * 1.5, true)
		# big circle
		draw_circle(line_end_pos, ball.radius, drag_color, true, -1.0, true)
		draw_circle(line_end_pos, ball.radius/2, drag_color, true, -1.0, true)
		# small circle
		draw_circle(ball.position + (ball.position - line_end_pos) / 2, ball.radius / 2, drag_color, true, -1.0, true)

	# ball
	draw_circle(ball.position, ball.radius, ball.color, true, -1.0, true)
	ball.color.v = clamp(ball.color.v + .01, 0, 1)
	ball.color.s = clamp(ball.color.s - .01, 0, 1)
	ball.color.a = clamp(ball.color.a + .1, 0, 1)
