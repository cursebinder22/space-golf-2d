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

func _process(delta: float) -> void:
	# fix overlapping planets and keep on screen
	for planet in planets:
		for other_planet in planets:
			if other_planet != planet:
				var dist_btwn = planet.position.distance_to(other_planet.position)
				var dir_away = (planet.position - other_planet.position).normalized()
				if dist_btwn < 3 + planet.radius + other_planet.radius:
					planet.position += dir_away
		planet.position.x = clamp(planet.position.x, planet_rim_width + planet.radius, view_size.x - planet.radius - planet_rim_width)
		planet.position.y = clamp(planet.position.y, planet_rim_width + planet.radius, view_size.y - planet.radius - planet_rim_width)
	
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
		
func _draw() -> void:
	for star in stars:
		# lux contingent on radius, affects color
		var lux = (star.radius - min_star_radius) / (max_star_radius - min_star_radius)
		var color = Color(lux, lux, lux)
		draw_circle(star.position, star.radius, color, true, -1.0, true)
	
	for planet in planets:
		var element = elements[planet.element]
		var card_size = element.card.get_size() * 2
		var rect = Rect2(planet.position - card_size / 2, card_size)
		draw_circle(planet.position, planet.radius, Color(0,0,0), true)
		draw_texture_rect(element.card, rect, false)
		draw_circle(planet.position, planet.radius, element.color, false, planet_rim_width, true)
