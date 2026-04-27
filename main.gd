extends Node2D

# star variables, includes viewport size get
var stars = []
const star_density = 1 / 1000.
@onready var view_size = get_viewport().size
@onready var total_stars = view_size.x * view_size.y * star_density
const min_star_radius = .5
const max_star_radius = 1.5
const max_star_flux = 1
const max_star_speed = 10
const planet_rim_width = 1.5

# core element names
enum Element {SIGHT, MIGHT, LIGHT, EARTH, FIRE, ENERGY, NATURE, AIR, ICE, WATER, MAGIC, LOVE}

# detailed element info
var elements = {
	Element.EARTH: {
		'color': Color(1,0,0),
		'description': 'The Red Volcano',
		'card': preload('res://images/cards/earth.png'),
		'row': 7,
		'column': 2
	},
	Element.FIRE: {
		'color': Color(1,.5,0),
		'description': 'The Orange Torch',
		'card': preload('res://images/cards/fire.png'),
		'row': 5,
		'column': 2
	},
	Element.ENERGY: {
		'color': Color(1,1,0),
		'description': 'The Yellow Spark',
		'card': preload('res://images/cards/energy.png'),
		'row': 3,
		'column': 2
	},
	Element.NATURE: {
		'color': Color(0,1,0),
		'description': 'The Green Tree',
		'card': preload('res://images/cards/nature.png'),
		'row': 1,
		'column': 2
	},
	Element.AIR: {
		'color': Color(0,1,1),
		'description': 'The Cyan Cloud',
		'card': preload('res://images/cards/air.png'),
		'row': 1,
		'column': 0
	},
	Element.ICE: {
		'color': Color(0,.5,1),
		'description': 'The Cerulean Star',
		'card': preload('res://images/cards/ice.png'),
		'row': 3,
		'column': 0
	},
	Element.WATER: {
		'color': Color(0,0,1),
		'description': 'The Cobalt Droplet',
		'card': preload('res://images/cards/water.png'),
		'row': 5,
		'column': 0
	},
	Element.MAGIC: {
		'color': Color(.5,0,1),
		'description': 'The Purple Crystal',
		'card': preload('res://images/cards/magic.png'),
		'row': 7,
		'column': 0
	},
	Element.LOVE: {
		'color': Color(1,0,1).lightened(.5),
		'description': 'The Pink Heart',
		'card': preload('res://images/cards/love.png'),
		'row': 0,
		'column': 1
	},
	Element.LIGHT: {
		'color': Color(1,1,1),
		'description': 'The White Sun',
		'card': preload('res://images/cards/light.png'),
		'row': 2,
		'column': 1
	},
	Element.MIGHT: {
		'color': Color(.66,.66,.66),
		'description': 'The Gray Moon',
		'card': preload('res://images/cards/might.png'),
		'row': 4,
		'column': 1
	},
	Element.SIGHT: {
		'color': Color(.33,.33,.33),
		'description': 'The Black Eye',
		'card': preload('res://images/cards/sight.png'),
		'row': 6,
		'column': 1
	}
}

# planet variables
var planets = []
var total_planets = Element.size()

@onready var ball = {
	'position': Vector2(view_size.x / 2, 4 * view_size.y / 9),
	'speed': 0, 
	'direction': Vector2.ZERO,
	'radius': 10,
	'gravity': Vector2.ZERO,
	'planet': null,
	'color': Color.WHITE
}

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
		var planet_x = view_size.x / 4 + elements[element].column * view_size.x / 4
		var planet_y = view_size.y / 9 + elements[element].row * view_size.y / 9
		planets.append({
			'position': Vector2(planet_x, planet_y),
			'radius': min(view_size.x, view_size.y) / 8,
			'element': element
		})

var click_start_pos: Vector2
var click_end_pos: Vector2
var click_drag_pos: Vector2
var draw_drag_line = false
var fade_drag_line = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				click_start_pos = event.position
				draw_drag_line = true
				fade_drag_line = false
			else:
				click_end_pos = event.position
				fade_drag_line = true
				ball.direction = (-click_end_pos + click_start_pos).normalized()
				ball.speed = click_end_pos.distance_to(click_start_pos) / 50
				ball.orbit_planet = null

func _process(delta: float) -> void:
	# for draw function's ball drag line
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		click_drag_pos = get_global_mouse_position()
	
	# ball gravity physics if it has touched a planet since last launch
	if ball.planet != null:
		var altitude = ball.position.distance_to(ball.planet.position) - ball.planet.radius
		ball.gravity = 10 * (-ball.position + ball.planet.position).normalized() / altitude
		var xv = ball.speed * ball.direction.x + ball.gravity.x
		var yv = ball.speed * ball.direction.y + ball.gravity.y
		ball.speed = sqrt(xv**2 + yv**2)
		ball.direction = Vector2(xv, yv).normalized()
	ball.position += ball.speed * ball.direction
	
	for planet in planets:
		var dist = ball.position.distance_to(planet.position)
		var min_dist = ball.radius + planet.radius + planet_rim_width
		# if touching planet, apply gravity
		if dist < min_dist:
			ball.planet = planet
			var planet_to_ball_dir = (ball.position - planet.position).normalized()
			ball.position = planet.position + min_dist * planet_to_ball_dir
			# slow ball with every surface contact to represent friction 
			ball.speed *= .9
			# bounce ball on planet surface
			var angle_to_tangent = -ball.direction.angle_to(planet_to_ball_dir)
			ball.direction = -ball.direction.rotated(-angle_to_tangent * 2)
			
	# bounce ball on screen edges
	if ball.position.x < ball.radius \
	or ball.position.x > view_size.x - ball.radius \
	or ball.position.y < ball.radius \
	or ball.position.y > view_size.y - ball.radius:
		ball.position.x = clamp(ball.position.x, ball.radius, view_size.x - ball.radius)
		ball.position.y = clamp(ball.position.y, ball.radius, view_size.y - ball.radius)
		ball.speed *= .1
		ball.direction *= -1
		ball.color.a = 0
	
	for star in stars:
		# move via constructed velocity
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
	
	# for _draw()
	queue_redraw()
		
var line_end_pos: Vector2
var drag_color: Color
func _draw() -> void:
	# draw stars
	for star in stars:
		# lux contingent on radius, affects color
		var lux = (star.radius - min_star_radius) / (max_star_radius - min_star_radius)
		var color = Color(lux, lux, lux)
		draw_circle(star.position, star.radius, color, true, -1.0, true)
	
	# draw planets
	for planet in planets:
		var element = elements[planet.element]
		var card_size = element.card.get_size() * 2
		var rect = Rect2(planet.position - card_size / 2, card_size)
		draw_circle(planet.position, planet.radius, Color(0,0,0), true)
		draw_texture_rect(element.card, rect, false)
		draw_circle(planet.position, planet.radius, element.color, false, planet_rim_width, true)
	
	# draw drag line and dots
	if draw_drag_line:
		var dist = click_start_pos.distance_to(click_drag_pos)
		var ratio = clamp(dist / min(view_size.x, view_size.y), 0, 1)
		if not fade_drag_line:
			line_end_pos = ball.position - (click_drag_pos - click_start_pos) / 4
			drag_color = Color.from_hsv(ratio, 1, 1)
		else:
			drag_color.a -= .1
			if drag_color.v < .1:
				draw_drag_line = false
		draw_line(ball.position, line_end_pos, drag_color, planet_rim_width * 1.25, true)
		# big circle
		draw_circle(line_end_pos, ball.radius, drag_color, true, -1.0, true)
		draw_circle(line_end_pos, ball.radius/2, drag_color, true, -1.0, true)
		# small circle
		draw_circle(ball.position + (ball.position - line_end_pos) / 2, ball.radius / 2, drag_color, true, -1.0, true)

	# draw ball
	draw_circle(ball.position, ball.radius, ball.color, true, -1.0, true)
	ball.color.a = clamp(ball.color.a + .1, 0, 1)
