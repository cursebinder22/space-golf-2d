extends Node2D

# window info
@onready var game_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var game_height = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var min_game_size = min(game_width, game_height)

# friction info
const high_friction = .2
const normal_friction = .1
const low_friction = .01

# planet info
const drift_speed = .01
var planets = []
@onready var total_planets = Element.size()

# meta
var true_line_width = 1.0
var line_width = true_line_width
const anti_alias = true

# ball info
@onready var ball = {
	'position': Vector2(game_width/2, game_height/2),
	'speed': 0, 
	'direction': Vector2.ZERO,
	'radius': 2,
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

# flag info
var flag = {
	'planet': null,
	'form': [
		[[0,0], [0,-4], Color.WHITE],
		[[0,-4], [0,-6], Color.RED],
		[[0,-6], [2,-5], Color.RED],
		[[2,-5], [0,-4], Color.RED]
	]
}

func draw_flag():
	var draw_scale = 2
	var base = flag.planet.position
	base.y -= flag.planet.radius
	for line in flag.form:
		var p1 = base + Vector2(line[0][0] * draw_scale, line[0][1] * draw_scale)
		var p2 = base + Vector2(line[1][0] * draw_scale, line[1][1] * draw_scale)
		var c = line[2]
		draw_line(p1, p2, c, line_width, anti_alias)

# character info
const characters = {
	'0': [
		[[0,3],[0,1],[1,0],[2,1],[2,3],[1,4],[0,3]],
		[[1,2]]
	],
	'1': [
		[[0,1],[1,0],[1,4]],
		[[0,4],[1,3],[2,4]]
	],
	'2': [
		[[1,1],[0,1],[1,0],[2,1],[0,3],[0,4],[2,4],[2,3]]
	],
	'3': [
		[[1,1],[0,1],[1,0],[2,1],[1,2],[0,2]],
		[[1,2],[2,3],[1,4],[0,3],[1,3]]
	],
	'4': [
		[[0,1],[1,0],[1,2],[3,2]],
		[[3,1],[2,0],[2,4],[3,3]]
	],
	'5': [
		[[1,0],[2,1],[0,1],[0,2],[1,2],[2,3],[1,4],[0,3],[1,3]]
	],
	'6': [
		[[2,1],[3,1],[2,0],[1,1],[1,3],[2,4],[3,3],[2,2],[0,4]]
	],
	'7': [
		[[1,0],[0,1],[3,1],[0,4]]
	],
	'8': [
		[[1,2],[0,1],[1,0],[2,1],[0,3],[1,4],[2,3],[1,2]],
		[[0,2],[2,2]]
	],
	'9': [
		[[2,1],[1,0],[0,1],[1,2],[2,1],[2,4],[3,3]]
	],
	'A': [
		[[0,3],[1,4],[1,0],[2,0],[2,4],[3,3]],
		[[0,0],[1,1],[2,1],[3,0]]
	],
	'a': [
		[[1,2],[0,3],[1,4],[2,3],[1,2]],
		[[2,2],[2,4],[3,3]]
	],
	'B': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[3,1],[2,2],[0,2]],
		[[2,2],[3,3],[2,4],[1,3]]
	],
	'b': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,3],[2,2],[3,3],[2,4],[1,3]]
	],
	'C': [
		[[2,0],[2,1],[1,0],[0,1],[0,3],[1,4],[2,3],[2,4]]
	],
	'c': [
		[[1,1],[2,2],[1,2],[0,3],[1,4],[2,3]]
	],
	'D': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[3,1],[3,3],[2,4],[1,3]]
	],
	'd': [
		[[3,1],[2,0],[2,4],[3,3]],
		[[2,3],[1,2],[0,3],[1,4],[2,3]]
	],
	'E': [
		[[1,0],[1,4]],
		[[0,2],[2,2]],
		[[0,0],[1,1],[2,0],[3,1],[2,1]],
		[[0,4],[1,3],[2,4],[3,3],[2,3]]
	],
	'e': [
		[[0,2],[0,3],[2,3],[2,2],[1,2],[1,4],[2,4],[3,3]]
	],
	'F': [
		[[1,0],[1,4],[0,3]],
		[[0,2],[2,2]],
		[[0,0],[1,1],[2,0],[3,1],[2,1]]
	],
	'f': [
		[[2,1],[1,0],[1,4],[0,3]],
		[[0,2],[2,2]]
	],
	'G': [
		[[2,0],[2,1],[1,0],[0,1],[0,3],[1,4],[2,3],[2,2],[1,3]]
	],
	'g': [
		[[3,3],[2,2],[2,5],[1,6],[0,5],[1,5]],
		[[2,3],[1,2],[0,3],[1,4],[2,3]]
	],
	'H': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[3,1],[2,0],[2,4],[3,3]],
		[[0,2],[3,2]]
	],
	'h': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,3],[2,2],[2,4],[3,3]]
	],
	'I': [
		[[1,0],[1,4]],
		[[0,0],[1,1],[2,0]],
		[[0,4],[1,3],[2,4]]
	],
	'i': [
		[[0,3],[1,2],[1,4],[2,3]],
		[[1,1]]
	],
	'J': [
		[[2,0],[2,3],[1,4],[0,3],[1,3]],
		[[3,0],[2,1],[1,0],[0,1],[1,1]]
	],
	'j': [
		[[2,3],[1,2],[1,5],[0,6],[-1,5],[0,5]],
		[[1,1]]
	],
	'K': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[0,2],[1,2],[2,1],[2,0],[3,1]],
		[[1,2],[2,3],[2,4],[3,3]]
	],
	'k': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,2],[2,2],[2,1]],
		[[1,2],[3,4],[3,3]]
	],
	'L': [
		[[0,1],[1,0],[1,4]],
		[[0,4],[1,3],[2,4],[3,3],[2,3]]
	],
	'l': [
		[[0,1],[1,0],[1,4],[2,3]]
	],
	'M': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[2,4]],
		[[2,1],[3,0],[3,4],[4,3]]
	],
	'm': [
		[[0,3],[1,2],[1,4]],
		[[1,3],[2,2],[2,4]],
		[[2,3],[3,2],[3,4],[4,3]]
	],
	'N': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[2,4],[3,3]]
	],
	'n': [
		[[0,3],[1,2],[1,4]],
		[[1,3],[2,2],[2,4],[3,3]]
	],
	'O': [
		[[0,3],[0,1],[1,0],[2,1],[2,3],[1,4],[0,3]],
		[[1,1],[1,3]]
	],
	'o': [
		[[0,3],[1,2],[2,3],[1,4],[0,3]],
		[[1,1],[1,5]]
	],
	'P': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[3,1],[2,2],[0,2]]
	],
	'p': [
		[[0,3],[1,2],[1,6],[0,5]],
		[[1,3],[2,2],[3,3],[2,4],[1,3]]
	],
	'Q': [
		[[0,3],[0,1],[1,0],[2,1],[2,3],[1,4],[0,3]],
		[[1,3],[2,4],[3,3]]
	],
	'q': [
		[[3,3],[2,2],[2,6],[3,5]],
		[[2,3],[1,2],[0,3],[1,4],[2,3]]
	],
	'R': [
		[[0,1],[1,0],[1,4],[0,3]],
		[[1,1],[2,0],[3,1],[2,2],[0,2]],
		[[1,2],[3,4],[3,3]]
	],
	'r': [
		[[0,3],[1,2],[1,4]],
		[[1,3],[2,2],[3,3],[3,2]]
	],
	'S': [
		[[1,1],[2,1],[1,0],[0,1],[2,3],[1,4],[0,3],[1,3]]
	],
	's': [
		[[1,1],[2,2],[1,2],[0,3],[2,3],[1,4],[0,4],[0,5]]
	],
	'T': [
		[[2,0],[2,4],[3,3]],
		[[1,0],[0,1],[4,1],[3,0]]
	],
	't': [
		[[1,0],[1,4],[2,3]],
		[[0,1],[2,1]]
	],
	'U': [
		[[0,1],[1,0],[1,4],[2,4],[2,0],[3,1]]
	],
	'u': [
		[[0,3],[1,2],[1,4],[2,4],[2,2]]
	],
	'V': [
		[[0,1],[1,0],[1,4],[3,2],[3,0],[4,1]]
	],
	'v': [
		[[0,3],[1,2],[1,4],[3,2]]
	],
	'W': [
		[[0,1],[1,0],[1,4],[2,3],[2,0]],
		[[2,3],[3,4],[3,0],[4,1]]
	],
	'w': [
		[[0,3],[1,2],[1,4],[2,3],[2,2]],
		[[2,3],[3,4],[3,2]]
	],
	'X': [
		[[0,1],[1,0],[1,1],[3,3],[3,4],[4,3]],
		[[0,3],[1,4],[1,3],[3,1],[3,0],[4,1]]
	],
	'x': [
		[[0,3],[0,2],[2,4],[2,3]],
		[[0,4],[2,2]]
	],
	'Y': [
		[[0,1],[1,0],[1,1],[2,2],[3,1],[3,0],[4,1]],
		[[2,0],[2,4],[1,3]]
	],
	'y': [
		[[0,3],[1,2],[1,3],[2,4],[2,2],[3,3]],
		[[2,4],[2,5],[1,6],[0,5],[1,5]]
	],
	'Z': [
		[[1,0],[0,1],[3,1],[0,4],[2,4],[3,3],[3,4]]
	],
	'z': [
		[[1,1],[0,2],[2,2],[0,4],[2,4],[2,3]]
	],
	'?': [
		[[2,1],[1,1],[2,0],[3,1],[2,2],[2,3],[3,2]],
		[[2,4]]
	],
	'!': [
		[[1,3],[1,1],[2,0],[2,2],[1,3]],
		[[1,4]]
	],
	'-': [
		[[0,2],[2,2]]
	],
	'.': [
		[[1,4]]
	],
	',': [
		[[1,4],[1,5],[0,6]]
	],
	';': [
		[[1,4],[1,5],[0,6]],
		[[1,2]]
	],
	':': [
		[[1,1]],
		[[1,3]]
	],
	'(': [
		[[1,0],[0,1],[0,3],[1,4]]
	],
	')': [
		[[0,0],[1,1],[1,3],[0,4]]
	],
	"'": [
		[[1,-1],[1,0],[0,1]]
	]
}

func draw_text(text: String, top_left: Vector2, height: float = 16, color: Color = Color.WHITE):
	var cell_size = height/4
	var new_line = height * 1.5
	var next_char_x = top_left.x
	for character in text:
		if character == '\\':
			next_char_x = top_left.x
			top_left.y += new_line
		elif character == ' ':
			next_char_x += height/2
		else:
			var max_x = next_char_x
			var lines = characters[character]
			for line in lines:
				if len(line) == 1: # draw dot (not line)
					var dot_pos = Vector2(next_char_x, top_left.y)
					dot_pos.x += line[0][0] * cell_size
					dot_pos.y += line[0][1] * cell_size
					draw_circle(dot_pos, 2, color, false, line_width, anti_alias)
					max_x = max(max_x, dot_pos.x)
				else: # draw line
					for pair_i in len(line) - 1:
						var p1 = Vector2(next_char_x, top_left.y) 
						p1.x += line[pair_i][0] * cell_size
						p1.y += line[pair_i][1] * cell_size
						var p2 = Vector2(next_char_x, top_left.y)
						p2.x += line[pair_i + 1][0] * cell_size
						p2.y += line[pair_i + 1][1] * cell_size
						draw_line(p1, p2, color, line_width, anti_alias)
						max_x = max(max_x, p1.x, p2.x)
			if max_x < game_width - height:
				next_char_x = max_x
			else:
				next_char_x = top_left.x
				top_left.y += new_line

# get next rank up of element
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
		var planet_radius = game_width/10 * randf_range(.5, 1.5)
		var planet_x = randf_range(0, game_width)
		var planet_y = randf_range(0, game_height)
		planets.append({
			'position': Vector2(planet_x, planet_y),
			'direction': Vector2.RIGHT.rotated(randf_range(0, TAU)),
			'radius': planet_radius,
			'element': element
		})
		for planet in planets:
			if planet.element == Element.EARTH:
				flag.planet = planet

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_start_pos = event.position
				draw_drag_line = true
				fade_drag_line = false
				ball.speed = 0
			else: # release click
				line_width *= 2
				click_end_pos = event.position
				fade_drag_line = true
				ball.direction = (-click_end_pos + click_start_pos).normalized()
				ball.speed = click_end_pos.distance_to(click_start_pos) / 50
				if ball.planet != null:
					ball.color = elements[ball.planet.element].color
				ball.planet = null

func _process(_delta: float) -> void:
	line_width = lerp(line_width, true_line_width, .1)
	
	# for draw function's drag line
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_drag_pos = get_global_mouse_position()
	
	# basic ball movement (before collision & wrapping)
	ball.position += ball.speed * ball.direction
	if ball.planet != null:
		ball.position += drift_speed * ball.planet.direction # keeps ball from sliding behind planet motion
	
	# planets: drift within boundaries
	for planet in planets:
		planet.position += drift_speed * planet.direction
		for other_planet in planets:
			var pp_dist = planet.position.distance_to(other_planet.position)
			var min_pp_dist = planet.radius + other_planet.radius + ball.radius * 2
			
			if other_planet != planet and pp_dist < min_pp_dist:
				planet.position = other_planet.position + min_pp_dist * other_planet.position.direction_to(planet.position)
				planet.direction = other_planet.position.direction_to(planet.position)
				
				other_planet.position = planet.position + min_pp_dist * planet.position.direction_to(other_planet.position)
				other_planet.direction = planet.position.direction_to(other_planet.position)
			
		if planet.position.x < planet.radius + 2 * ball.radius:
			planet.direction.x *= -1
			planet.position.x = planet.radius + 2 * ball.radius
			
		elif planet.position.x > game_width - planet.radius - 2 * ball.radius:
			planet.direction.x *= -1
			planet.position.x = game_width - planet.radius - 2 * ball.radius
		
		if planet.position.y < planet.radius + 2 * ball.radius:
			planet.direction.y *= -1
			planet.position.y = planet.radius + 2 * ball.radius
			
		elif planet.position.y > game_height - planet.radius - 2 * ball.radius:
			planet.direction.y *= -1
			planet.position.y = game_height - planet.radius - 2 * ball.radius
		
		# transfer ownership if ball collision
		var bp_dist = ball.position.distance_to(planet.position)
		var min_bp_dist = ball.radius + planet.radius
		if bp_dist < min_bp_dist:
			ball.planet = planet
	
	# ball impact on screen edges
	var impact = false
	
	if ball.position.x < ball.radius:
		ball.position.x = ball.radius
		ball.direction.x *= -1
		impact = true
		
	elif ball.position.x > game_width - ball.radius:
		ball.position.x = game_width - ball.radius
		ball.direction.x *= -1
		impact = true
	
	if ball.position.y < ball.radius:
		ball.position.y = ball.radius
		ball.direction.y *= -1
		impact = true
		
	elif ball.position.y > game_height - ball.radius:
		ball.position.y = game_height - ball.radius
		ball.direction.y *= -1
		impact = true
		
	if impact:
		ball.speed /= 2
		ball.color.a = 0
		ball.planet = null
	
	# planet-magnetized ball rolling behavior
	if ball.planet != null:
		var planet_to_ball_dir = (ball.position - ball.planet.position).normalized()
		var min_dist = ball.radius + ball.planet.radius
		var tangent = Vector2.from_angle(planet_to_ball_dir.angle() + TAU/4)
		
		ball.position = ball.planet.position + min_dist * planet_to_ball_dir
		ball.speed *= (1 - elements[ball.planet.element].friction) * ball.direction.dot(tangent)
		ball.direction = tangent
	
	# change flag position when ball is nearby
	var flag_base = flag.planet.position
	flag_base.y -= flag.planet.radius
	var fb_dist = flag_base.distance_to(ball.position)
	if fb_dist < ball.radius * 1.1: # works with 1.1 but not 1.0
		var next_element = order_up(flag.planet.element)
		for planet in planets:
			if planet.element == next_element:
				flag.planet = planet
	
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
	var border = Rect2(Vector2.ZERO, Vector2(game_width, game_height))
	draw_rect(border, Color(.1,.1,.1), false, line_width, anti_alias)
	
	for planet in planets:
		var planet_color = elements[planet.element].color
		if planet_color == Color.BLACK:
			draw_circle(planet.position, planet.radius, Color(.1,.1,.1), true, -1.0, anti_alias)
		
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

	draw_flag()
