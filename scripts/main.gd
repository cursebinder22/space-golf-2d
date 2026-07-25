extends Node2D

# game size
@onready var game_width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var game_height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var min_game_size: float = min(game_width, game_height)

# score
const par: int = 3
var shots_this_hole: int = 0
var score: int = 0

# planets
const drift_speed: float = .01
var planets: Array = []
@onready var total_planets: int = Element.size()

# click pos
var click_start_pos: Vector2 = Vector2.ZERO
var click_drag_pos: Vector2 = Vector2.ZERO
var click_end_pos: Vector2 = Vector2.ZERO

# draw args
const anti_alias: bool = true
var true_line_width: float = 1
var line_width: float = true_line_width

# drag line
var draw_drag_line: bool = false
var fade_drag_line: bool = false
@onready var max_drag_dist: float = min_game_size / 2
var drag_line_end_pos: Vector2 = Vector2.ZERO
var drag_color: Color = Color(0,0,0,0)
var drag_dist: float = 0

enum Element {EARTH, FIRE, ENERGY, NATURE, AIR, ICE, WATER, MAGIC, LOVE, LIGHT, MIGHT, SIGHT}
@onready var element_data = {
	Element.EARTH: EarthData,
	Element.FIRE: FireData,
	Element.ENERGY: EnergyData,
	Element.NATURE: {
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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
		'friction': FrictionTypes.low,
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

@onready var ball = {
	'position': Vector2(game_width/2, game_height/2),
	'speed': 0.0, 
	'direction': Vector2.ZERO,
	'radius': 2.0,
	'planet': null,
	'color': Color(1,1,1),
	'power': 0.0
}

var flag = {
	'planet': null,
	'form': FlagData.form
}

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

const shadow: Color = Color(1,1,1,.1) # very transparent white, looks dark gray on black
const default_text_height: int = 12

func draw_flag():
	var draw_scale: float = 2.0
	var base: Vector2 = flag.planet.position
	base.y -= flag.planet.radius
	
	for line in flag.form:
		var p1: Vector2 = base + Vector2(line[0][0] * draw_scale, line[0][1] * draw_scale)
		var p2: Vector2 = base + Vector2(line[1][0] * draw_scale, line[1][1] * draw_scale)
		var c: Color = line[2]
		
		draw_line(p1, p2, c, line_width, anti_alias)

func draw_text(text: String, top_left: Vector2, height: float = default_text_height, color: Color = shadow):
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
					draw_circle(dot_pos, height / default_text_height, color, false, line_width, anti_alias)
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
		if element_data[element].order + 1 == element_data[e].order:
			return e
	return Element.EARTH

@onready var min_planet_radius: float = min_game_size / 15
@onready var max_planet_radius: float = min_game_size / 6

@onready var launch_seconds: float = 1
@onready var launch_timer: Timer = Timer.new()

func _ready() -> void:	
	# nearest neighbor texture scaling
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# generate planets
	for i in range(total_planets):
		var element = Element.values()[i]
		var planet_radius = randf_range(min_planet_radius, max_planet_radius)
		var planet_x = randf_range(0, game_width)
		var planet_y = randf_range(0, game_height)
		planets.append({
			'position': Vector2(planet_x, planet_y),
			'direction': Vector2.RIGHT.rotated(randf_range(0, TAU)),
			'radius': planet_radius,
			'radius_speed': [-1,1].pick_random() * .01,
			'element': element
		})
		for planet in planets:
			if planet.element == Element.EARTH:
				flag.planet = planet
				
	# configure launch timer
	add_child(launch_timer)
	launch_timer.wait_time = launch_seconds
	launch_timer.autostart = false
	launch_timer.one_shot = true

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

@onready var cancel: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and launch_timer.is_stopped():
				cancel = true
				fade_drag_line = true
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				cancel = false
				click_start_pos = event.position
				draw_drag_line = true
				fade_drag_line = false
			elif not cancel: # release click
				click_end_pos = event.position
				shots_this_hole += 1
				launch_timer.start()
				await launch_timer.timeout
				
				# visual effects
				line_width *= 2
				fade_drag_line = true
				
				# launch ball
				var click_dist = click_end_pos.distance_to(click_start_pos)
				click_dist = clamp(click_dist, 0, max_drag_dist)
				ball.speed = click_dist / max_drag_dist
				ball.direction = (click_start_pos - click_end_pos).normalized()
				
				# ball color and planet
				if ball.planet != null:
					ball.color = element_data[ball.planet.element].color
				ball.planet = null

func _process(_delta: float) -> void:	
	# anti-bloom over time
	line_width = lerp(line_width, true_line_width, .01)
	
	# for draw function's drag line
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_drag_pos = get_global_mouse_position()
	
	# basic ball movement (before collision & wrapping)
	ball.position += ball.speed * ball.direction
	if ball.planet != null:
		ball.position += drift_speed * ball.planet.direction # keeps ball from sliding behind planet motion
	
	for planet in planets:
		# planets: grow or shrink size
		planet.radius += planet.radius_speed
		if planet.radius <= min_planet_radius:
			planet.radius = min_planet_radius
			planet.radius_speed = abs(planet.radius_speed)
		elif planet.radius >= max_planet_radius:
			planet.radius = max_planet_radius
			planet.radius_speed = -abs(planet.radius_speed)
		
		# planets: drift within boundaries
		planet.position += drift_speed * planet.direction
		for other_planet in planets:
			var pp_dist = planet.position.distance_to(other_planet.position)
			var min_pp_dist = planet.radius + other_planet.radius + ball.radius * 2 + .1
			
			if other_planet != planet and pp_dist < min_pp_dist:
				planet.position = other_planet.position + min_pp_dist * other_planet.position.direction_to(planet.position)
				planet.direction = other_planet.position.direction_to(planet.position)
				
				other_planet.position = planet.position + min_pp_dist * planet.position.direction_to(other_planet.position)
				other_planet.direction = planet.position.direction_to(other_planet.position)
			
		if planet.position.x < planet.radius + 2 * ball.radius + .1:
			planet.direction.x = abs(planet.direction.x)
			planet.position.x = planet.radius + 2 * ball.radius + .1
			
		elif planet.position.x > game_width - planet.radius - 2 * ball.radius - .1:
			planet.direction.x *= -abs(planet.direction.x)
			planet.position.x = game_width - planet.radius - 2 * ball.radius - .1
		
		if planet.position.y < planet.radius + 2 * ball.radius + .1:
			planet.direction.y = abs(planet.direction.y)
			planet.position.y = planet.radius + 2 * ball.radius + .1
			
		elif planet.position.y > game_height - planet.radius - 2 * ball.radius - .1:
			planet.direction.y = -abs(planet.direction.y)
			planet.position.y = game_height - planet.radius - 2 * ball.radius - .1
		
		# transfer ownership if ball collision
		if ball.planet != planet:
			var bp_dist = ball.position.distance_to(planet.position)
			var min_bp_dist = ball.radius + planet.radius
			if bp_dist < min_bp_dist:
				ball.planet = planet
	
	# ball impact on screen edges
	var impact = false
	
	if ball.position.x < ball.radius:
		ball.position.x = ball.radius
		ball.direction.x = abs(ball.direction.x)
		impact = true
		
	elif ball.position.x > game_width - ball.radius:
		ball.position.x = game_width - ball.radius
		ball.direction.x = -abs(ball.direction.x)
		impact = true
	
	if ball.position.y < ball.radius:
		ball.position.y = ball.radius
		ball.direction.y = abs(ball.direction.y)
		impact = true
		
	elif ball.position.y > game_height - ball.radius:
		ball.position.y = game_height - ball.radius
		ball.direction.y *= -abs(ball.direction.y)
		impact = true
		
	if impact:
		ball.speed *= .5
		ball.color.a = 0
		line_width *= .5
		ball.planet = null
	
	# planet-magnetized ball rolling behavior
	if ball.planet != null:
		var planet_to_ball_dir = (ball.position - ball.planet.position).normalized()
		var min_dist = ball.radius + ball.planet.radius
		var tangent = Vector2.from_angle(planet_to_ball_dir.angle() + TAU/4)
		
		ball.position = ball.planet.position + min_dist * planet_to_ball_dir
		ball.speed *= (1 - element_data[ball.planet.element].friction) * ball.direction.dot(tangent)
		ball.direction = tangent
	
	# change flag position when ball is nearby
	var flag_base = flag.planet.position
	flag_base.y -= flag.planet.radius
	var fb_dist = flag_base.distance_to(ball.position)
	if fb_dist < ball.radius * 1.1: # works with 1.1 but not 1.0
		var next_element = order_up(flag.planet.element)
		for planet in planets:
			if planet.element == next_element:
				# move flag to next planet and adjust score
				flag.planet = planet
				score += shots_this_hole - par
				shots_this_hole = 0
				line_width *= 2
	
	queue_redraw()

func draw_pattern(pattern_position: Vector2, element: Element, radius: float, color: Color, pattern_line_width: float = line_width):
	for from_point in element_data[element].pattern:
		for to_point in element_data[element].pattern[from_point]:
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
	draw_rect(border, shadow, false, line_width, anti_alias)
	
	for planet in planets:
		var planet_color = element_data[planet.element].color
		if planet_color == Color.BLACK:
			draw_circle(planet.position, planet.radius, shadow, true, -1.0, anti_alias)
		
		# largest central pattern
		draw_pattern(planet.position, planet.element, planet.radius * 2/3, planet_color)
		
		# planet surface rim
		draw_circle(planet.position, planet.radius, planet_color, false, line_width, anti_alias)
		
	# drag line and dots
	if draw_drag_line:
		var drag_angle = (click_drag_pos - click_start_pos).normalized()
		drag_dist = click_start_pos.distance_to(click_drag_pos)
		drag_dist = clamp(drag_dist, 0, max_drag_dist)
		
		if not fade_drag_line:
			drag_line_end_pos = ball.position - drag_dist / 2 * drag_angle
			drag_color = shadow
		else:
			drag_color.a -= .001
			if drag_color.a <= 0:
				draw_drag_line = false
		draw_line(ball.position, drag_line_end_pos, drag_color, line_width, anti_alias)
		draw_circle(drag_line_end_pos, ball.radius, drag_color, false, line_width, anti_alias)
		draw_circle(ball.position + (ball.position - drag_line_end_pos) / 2, ball.radius / 2, drag_color, false, line_width, anti_alias)
	
	# launch timer ring
	var ring_radius = drag_dist/2 * launch_timer.time_left / launch_seconds
	draw_circle(ball.position, ring_radius, shadow, false, line_width, anti_alias)
	
	# ball
	draw_circle(ball.position, ball.radius, ball.color, true, -1.0, anti_alias)
	ball.color.v = clamp(ball.color.v + .01, 0, 1)
	ball.color.s = clamp(ball.color.s - .01, 0, 1)
	ball.color.a = clamp(ball.color.a + .01, 0, 1)
	ball.power = ball.color.a * ball.color.s

	draw_flag()
