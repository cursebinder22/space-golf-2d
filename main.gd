extends Node2D

# window info
@onready var game_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var game_height = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var min_game_size = min(game_width, game_height)

# background info
@onready var background_points = PackedVector2Array([
	Vector2(0,0),
	Vector2(game_width,0),
	Vector2(game_width,game_height),
	Vector2(0,game_height)
])
@onready var background_colors = PackedColorArray([
	Color(0,0,0),
	Color(0,0,0),
	Color(.25,0,1),
	Color(.25,0,1)
])

# friction info
const high_friction = .2
const normal_friction = .1
const low_friction = .01
const anti_alias = true

# planet info
const drift_speed = 1
var planets = []
@onready var line_width = .5
@onready var total_planets = Element.size()

# ball info
@onready var normal_ball_radius = 4
@onready var ball = {
	'position': Vector2(game_width / 2, -2 * normal_ball_radius),
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
		'color': Color(.5,.5,.5),
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
		'color': Color(0,0,0),
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
	
	# generate planets
	for i in range(total_planets):
		var element = Element.values()[i]
		var planet_radius = min_game_size / 2**3
		var planet_x = game_width / 2 + elements[element].column * planet_radius * 2
		var planet_y = elements[element].row * game_height / 6 - planet_radius - line_width - normal_ball_radius * 2
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

func _process(_delta: float) -> void:
	# for draw function's drag line
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_drag_pos = get_global_mouse_position()
	
	# basic ball movement (before collision & wrapping)
	ball.position += ball.speed * ball.direction
	ball.position.y += drift_speed # keeps ball from sliding behind planet motion
	
	# planets: drift downward, wrap around screen
	for planet in planets:
		planet.position.y += drift_speed
		if planet.position.y > game_height + planet.radius + line_width + 2 * normal_ball_radius:
			planet.position.y -= game_height * 8/6
		
		# transfer ownership if ball collision
		var dist = ball.position.distance_to(planet.position)
		var min_dist = ball.radius + planet.radius + line_width
		if dist < min_dist:
			ball.planet = planet
	
	# wrap ball around screen edges
	if ball.position.x < -ball.radius:
		ball.position.x += game_width + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	elif ball.position.x > game_width + ball.radius:
		ball.position.x -= game_width + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	if ball.position.y < -ball.radius:
		ball.position.y += game_height + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	elif ball.position.y > game_height + ball.radius:
		ball.position.y -= game_height + 2 * ball.radius
		ball.color.a = 0
		ball.planet = null
	
	# planet-magnetized ball rolling behavior
	if ball.planet != null:
		var planet_to_ball_dir = (ball.position - ball.planet.position).normalized()
		var min_dist = ball.radius + ball.planet.radius + line_width*2
		var tangent = Vector2.from_angle(planet_to_ball_dir.angle() + TAU/4)
		ball.position = ball.planet.position + min_dist * planet_to_ball_dir
		ball.speed *= (1 - elements[ball.planet.element].friction) * ball.direction.dot(tangent)
		ball.direction = tangent
	
	# call draw function
	queue_redraw()

func draw_pattern(pattern_position: Vector2, element: Element, radius: float, color: Color, pattern_line_width: float = line_width):
	for from_point in elements[element].pattern:
		for to_point in elements[element].pattern[from_point]:
			var from_point_pos = pattern_position + Vector2(
				radius * cos(from_point * TAU/8),
				radius * -sin(from_point * TAU/8)
			)
			if str(to_point) == 'C':
				draw_line(from_point_pos, pattern_position, color, pattern_line_width, anti_alias)
			else:
				var to_point_pos = pattern_position + Vector2(
					radius * cos(to_point * TAU/8),
					radius * -sin(to_point * TAU/8)
				)
				draw_line(from_point_pos, to_point_pos, color, pattern_line_width, anti_alias)

func _draw() -> void:
	#draw_texture_rect(background, Rect2(0,0,game_width,game_height), false)
	draw_polygon(background_points, background_colors)
	
	for planet in planets:
		var planet_color = elements[planet.element].color
		
		# smaller corner patterns
		for from_point in elements[planet.element].pattern:
			var pattern_color = planet_color
			pattern_color.a = .25
			
			if str(from_point) == 'C':
				draw_pattern(planet.position, planet.element, planet.radius * 1/3, pattern_color)
			else:
				var from_point_pos = planet.position + Vector2(
					planet.radius * 2/3 * cos(from_point * TAU/8),
					planet.radius * 2/3 * -sin(from_point * TAU/8)
				)
				draw_pattern(from_point_pos, planet.element, planet.radius * 1/3, pattern_color)
		
		# largest central pattern
		draw_pattern(planet.position, planet.element, planet.radius * 2/3, planet_color)
		
		# planet surface rim
		draw_circle(planet.position, planet.radius, planet_color, false, line_width, anti_alias)
	
	# drag line and dots
	if draw_drag_line:
		var dist = click_start_pos.distance_to(click_drag_pos)
		var ratio = clamp(dist / min_game_size, 0, 1)
		if not fade_drag_line:
			line_end_pos = ball.position - (click_drag_pos - click_start_pos) / 4
			drag_color = Color.from_hsv(ratio, 1, 1)
		else:
			drag_color.a -= .1
			if drag_color.a <= 0:
				draw_drag_line = false
		draw_line(ball.position, line_end_pos, drag_color, line_width, anti_alias)
		draw_circle(line_end_pos, ball.radius, drag_color, false, line_width, anti_alias)
		draw_circle(ball.position + (ball.position - line_end_pos) / 2, ball.radius / 2, drag_color, false, line_width, anti_alias)

	# ball
	draw_circle(ball.position, ball.radius, ball.color, true, -1.0, anti_alias)
	ball.color.v = clamp(ball.color.v + .01, 0, 1)
	ball.color.s = clamp(ball.color.s - .01, 0, 1)
	ball.color.a = clamp(ball.color.a + .1, 0, 1)
