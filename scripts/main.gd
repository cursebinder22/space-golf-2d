extends Node2D

# ball
const max_launch_seconds: float = 1
var launch_timer: Timer = Timer.new()
var cancel_launch: bool = false
var ball: Ball = Ball.new(Vector2(Global.game_width/2, Global.game_height/2))

# aiming
const aim_alpha_factor: float = 1/3.
var draw_drag_line: bool = false
var fade_drag_line: bool = false
var drag_line_end_pos: Vector2 = Vector2.ZERO
var drag_color: Color = Color.TRANSPARENT
var drag_dist: float = 0
var max_drag_dist: float = Global.min_game_size / 2
var ring_radius: float = 0.0

# score (meta)
var flag = Flag.new()
var score: int = 0
var shots_this_hole: int = 0
var hole_text: String = ''

# score (draw)
const text_drift_speed: float = 0.25
var draw_launch_text: bool = false
var launch_text_pos: Vector2 = Vector2.ZERO
var draw_hole_text: bool = false
var hole_text_width: float = 0.0
var hole_text_pos: Vector2 = Vector2.ZERO
var par_text_pos: Vector2 = Vector2(Global.default_text_height / 2, Global.default_text_height / 2)
var hole_text_color: Color = Color.TRANSPARENT

# planets
const ghost_black: Color = Color(.25,.25,.25,.5)
var total_planets: int = Global.Element.size()
var element_data: Dictionary = {
	Global.Element.NONE: ElementData.new(),
	Global.Element.EARTH: EarthData.new(),
	Global.Element.FIRE: FireData.new(),
	Global.Element.ENERGY: EnergyData.new(),
	Global.Element.NATURE: NatureData.new(),
	Global.Element.AIR: AirData.new(),
	Global.Element.ICE: IceData.new(),
	Global.Element.WATER: WaterData.new(),
	Global.Element.MAGIC: MagicData.new(),
	Global.Element.LOVE: LoveData.new(),
	Global.Element.LIGHT: LightData.new(),
	Global.Element.MIGHT: MightData.new(),
	Global.Element.SIGHT: SightData.new(),
}

# click
var click_start_pos: Vector2 = Vector2.ZERO
var click_drag_pos: Vector2 = Vector2.ZERO
var click_end_pos: Vector2 = Vector2.ZERO

# aesthetic
const fade_rate: float = .01
const anti_alias: bool = true

# space, border
const space: Resource = preload("res://space.png")
var space_alpha: float = 0.0
var space_mod: Color = Color.TRANSPARENT
var border: Rect2 = Rect2(0, 0, Global.game_width, Global.game_height)

# title
const banner_color: Color = Color(0,0,0,1)
var show_title: bool = true
var title_width: float = 0.0
var subtitle_width: float = 0.0
var subtitle_color: Color = Color.TRANSPARENT
var title_pos: Vector2 = Vector2.ZERO
var subtitle_pos: Vector2 = Vector2.ZERO
var title_banner: Rect2 = Rect2(Vector2(0, Global.game_height / 2 - Global.default_text_height), Vector2(Global.game_width, Global.default_text_height * 2))
var subtitle_banner: Rect2 = Rect2(Vector2(0, title_banner.end.y + Global.default_text_height / 2), Vector2(Global.game_width, Global.default_text_height * 1.5))

######################
## HELPER FUNCTIONS ##
######################

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

## Returns an element with a rank of one higher than the element provided.
## (Overflow case returns an element of rank 1.)
func rank_up(element: Global.Element) -> Global.Element:
	for enum_element in Global.Element.values():
		if enum_element != Global.Element.NONE:
			if element_data[enum_element].rank == element_data[element].rank + 1:
				return enum_element
	# overflow case
	for enum_element in Global.Element.values():
		if enum_element != Global.Element.NONE:
			if element_data[enum_element].rank == 1:
				return enum_element
	return Global.Element.NONE # rank 0, not reached

######################

func _ready() -> void:
	# generate planets
	var planet_sizes: Array = []
	for i in Global.Element.size() - 1:
		planet_sizes.append(i)
	for element_i: int in range(1, total_planets):
		var planet_element: Global.Element = Global.Element.values()[element_i]
		
		var fraction: float = 1 / float(Global.Element.size() - 2)
		var size_number: int = planet_sizes.pop_at(randi() % planet_sizes.size())
		var radius_diff: float = (Global.max_planet_radius - Global.min_planet_radius)
		var planet_radius: float = Global.min_planet_radius + float(size_number) * fraction * radius_diff
		
		var planet_x: float = randf_range(0, Global.game_width)
		var planet_y: float = randf_range(0, Global.game_height)
		var planet_pos: Vector2 = Vector2(planet_x, planet_y)
		Global.planets.append(Planet.new(planet_pos, Global.drift_speed, planet_radius, planet_element))
	
	# place flag on planet of rank 1
	for planet: Planet in Global.planets:
		if element_data[planet.element].rank == 1:
			flag.planet = planet
	
	# launch timer
	add_child(launch_timer)
	launch_timer.autostart = false
	launch_timer.one_shot = true
	
	# for pixel aesthetic
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed and launch_timer.is_stopped():
				cancel_launch = true
				fade_drag_line = true
				
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				show_title = false
				cancel_launch = false
				click_start_pos = event.position
				draw_drag_line = true
				fade_drag_line = false
				
			elif not cancel_launch: # else = release click
				click_end_pos = event.position
				draw_launch_text = true
				launch_text_pos = ball.position
				launch_text_pos.y -= Global.default_text_height
				launch_timer.wait_time = max_launch_seconds * drag_dist / max_drag_dist
				launch_timer.start()
				await launch_timer.timeout
				draw_launch_text = false
				shots_this_hole += 1
				
				# aesthetic
				Global.line_width = clamp(Global.line_width * 2 * launch_timer.wait_time / max_launch_seconds, 0, Global.max_line_width)
				fade_drag_line = true
				
				# launch ball
				var click_dist: float = click_end_pos.distance_to(click_start_pos)
				click_dist = clamp(click_dist, 0, max_drag_dist)
				ball.speed = click_dist / max_drag_dist
				ball.direction = (click_start_pos - click_end_pos).normalized()
				
				# ball color and planet
				if ball.planet != null:
					ball.color = element_data[ball.planet.element].color
				ball.planet = null

func _process(_delta: float) -> void:
	# aesthetic
	Global.line_width = lerp(Global.line_width, Global.true_line_width, fade_rate)
	if draw_launch_text:
		launch_text_pos.y -= text_drift_speed
	if draw_hole_text:
		hole_text_pos.x += text_drift_speed
		if hole_text_pos.x > Global.game_width - hole_text_width - Global.default_text_height / 2:
			draw_hole_text = false
	
	# fade ball color
	ball.color.v = clamp(ball.color.v + fade_rate, 0, 1)
	ball.color.s = clamp(ball.color.s - fade_rate, 0, 1)
	ball.color.a = clamp(ball.color.a + fade_rate, 0, 1)
	
	if draw_drag_line:
		# drag line meta
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			click_drag_pos = get_global_mouse_position()
		var drag_angle: Vector2 = (click_drag_pos - click_start_pos).normalized()
		drag_dist = click_start_pos.distance_to(click_drag_pos)
		drag_dist = clamp(drag_dist, 0, max_drag_dist)
		
		# color management
		if not fade_drag_line:
			drag_line_end_pos = ball.position - drag_dist / 2 * drag_angle
			drag_color = ball.color
			drag_color.a *= aim_alpha_factor
		else:
			drag_color.h = ball.color.h
			drag_color.s = ball.color.s
			drag_color.v = ball.color.v
			drag_color.a -= fade_rate
			if drag_color.a <= 0:
				draw_drag_line = false
	
	# physics
	ball.move()
	for planet in Global.planets:
		planet.tick()
		planet.move()
		
		# transfer ownership if ball collision
		if ball.planet != planet:
			var bp_dist: float = ball.position.distance_to(planet.position)
			var min_bp_dist: float = ball.radius + planet.radius
			if bp_dist < min_bp_dist:
				ball.planet = planet
	
	# change flag position when ball is nearby
	flag.tick()
	if ball.planet == flag.planet and ball.planet != null:
		var ball_angle: float = ball.planet.position.angle_to_point(ball.position)
		var flag_angle: float = flag.planet.position.angle_to_point(flag.position)
		var angle_btwn: float = abs(angle_difference(ball_angle, flag_angle))
		if angle_btwn < TAU/4:
			flag.lift += .5
		if angle_btwn < TAU/64:
			var next_element = rank_up(flag.planet.element)
			for planet in Global.planets:
				if planet.element == next_element:
					# move flag to next planet and adjust score
					score += shots_this_hole - Global.par
					if flag.planet.element == Global.Element.SIGHT:
						Global.par += 1
						score = 0
					hole_text_pos = ball.position
					hole_text_pos.x = Global.default_text_height / 2
					hole_text_pos.y = clamp(hole_text_pos.y - Global.default_text_height * 1.5, Global.default_text_height * 2, Global.game_height - Global.default_text_height * 1.5)
					draw_hole_text = true
					Global.line_width = clamp(Global.line_width * 2, 0, Global.max_line_width)
					flag.planet = planet
					if ball.planet != null:
						ball.color = element_data[ball.planet.element].color
					hole_text_color = ball.color
					hole_text = 'Score: ' + str(score) + ' (' + str(shots_this_hole) + ')'
					shots_this_hole = 0
	
	queue_redraw()

##################
## DRAW HELPERS ##
##################

func draw_symbol(pattern_position: Vector2, element: Global.Element, radius: float, color: Color, pattern_line_width: float = Global.line_width, tilt: float = 0.0):
	for from_point: Variant in element_data[element].symbol:
		for to_point: Variant in element_data[element].symbol[from_point]:
			var from_point_pos: Vector2 = pattern_position + Vector2(
				radius * cos(tilt + TAU/8 * from_point),
				radius * -sin(tilt + TAU/8 * from_point)
			)
			if str(to_point) == 'C':
				draw_line(from_point_pos, pattern_position, color, pattern_line_width, anti_alias)
			else:
				var to_point_pos: Vector2 = pattern_position + Vector2(
					radius * cos(tilt + TAU/8 * to_point),
					radius * -sin(tilt + TAU/8 * to_point)
				)
				draw_line(from_point_pos, to_point_pos, color, pattern_line_width, anti_alias)

func draw_flag():
	var draw_scale: float = 2.0
	
	for line: Array in flag.get_rotated_form():
		var p1: Vector2 = flag.position + Vector2(line[0][0] * draw_scale, line[0][1] * draw_scale)
		var p2: Vector2 = flag.position + Vector2(line[1][0] * draw_scale, line[1][1] * draw_scale)
		var flag_color: Color = line[2]
		
		if flag_color == Color.TRANSPARENT:
			var new_color: Color = element_data[flag.planet.element].color
			if new_color != Color(0,0,0):
				flag_color = new_color
			else: flag_color = ghost_black
		
		draw_line(p1, p2, flag_color, Global.line_width, anti_alias)

func draw_text(text: String, top_left: Vector2, height: float = Global.default_text_height, color: Color = Color(1,1,1), wrap_text: bool = false) -> float:
	var cell_size: float = height/4
	var new_line: float = height * 1.5
	var next_char_x: float = top_left.x
	for character: String in text:
		if character == '\\':
			next_char_x = top_left.x
			top_left.y += new_line
		elif character == ' ':
			next_char_x += height/2
		else:
			var max_x: float = next_char_x
			var lines: Array = Global.charset[character]
			for line: Array in lines:
				if len(line) == 1: # draw dot (not line)
					var dot_pos: Vector2 = Vector2(next_char_x, top_left.y)
					dot_pos.x += line[0][0] * cell_size
					dot_pos.y += line[0][1] * cell_size
					draw_circle(dot_pos, height / Global.default_text_height, color, true, -1.0, anti_alias)
					max_x = max(max_x, dot_pos.x)
				else: # draw line
					for pair_i: int in len(line) - 1:
						var p1: Vector2 = Vector2(next_char_x, top_left.y) 
						p1.x += line[pair_i][0] * cell_size
						p1.y += line[pair_i][1] * cell_size
						
						var p2: Vector2 = Vector2(next_char_x, top_left.y)
						p2.x += line[pair_i + 1][0] * cell_size
						p2.y += line[pair_i + 1][1] * cell_size
						
						draw_line(p1, p2, color, Global.line_width, anti_alias)
						max_x = max(max_x, p1.x, p2.x)
			next_char_x = max_x
			if wrap_text:
				if max_x < Global.game_width - height:
					next_char_x = max_x
				else:
					next_char_x = top_left.x
					top_left.y += new_line
	return next_char_x - top_left.x # width of drawn text

##################

func _draw() -> void:
	# space
	space_alpha = Global.line_width / Global.true_line_width
	space_mod = Color(1,1,1,space_alpha)
	draw_texture(space, Vector2.ZERO, space_mod)
	
	# border
	if not show_title:
		var border_color = ball.color
		border_color.a *= aim_alpha_factor
		draw_rect(border, border_color, false, Global.line_width, anti_alias)
	
	# planet rims, patterns, etc.
	for planet in Global.planets:
		var planet_color: Color = element_data[planet.element].color
		#if planet_color == Color.BLACK:
			## black planet background to prevent invisibility
			#draw_circle(planet.position, planet.radius, ghost_black.darkened(1 - Global.line_width / Global.true_line_width), true, -1.0, anti_alias)
		draw_circle(planet.position, planet.radius, planet_color, false, Global.line_width, anti_alias)
		if not show_title:
			draw_symbol(planet.position, planet.element, planet.radius * 2/3, planet_color, Global.line_width, planet.tilt)
			
			# tick marks along radius
			for i in range(0, 8):
				var base_angle = i * TAU/8
				
				var x1: float = planet.radius * cos(base_angle + planet.tilt)
				var y1: float = planet.radius * -sin(base_angle + planet.tilt)
				var p1: Vector2 = Vector2(x1, y1) + planet.position
				
				var x2: float = planet.radius * 7/8 * cos(base_angle + planet.tilt)
				var y2: float = planet.radius * 7/8 * -sin(base_angle + planet.tilt)
				var p2: Vector2 = Vector2(x2, y2) + planet.position
				
				draw_line(p1, p2, planet_color, Global.line_width, anti_alias)
		
	# drag line and rings
	if draw_drag_line:
		draw_line(ball.position, drag_line_end_pos, drag_color, Global.line_width, anti_alias)
		draw_circle(drag_line_end_pos, ball.radius, drag_color, false, Global.line_width, anti_alias)
		#draw_circle(ball.position + (ball.position - drag_line_end_pos) / 2, ball.radius / 2, drag_color, true, -1.0, anti_alias)
	
	# launch timer ring
	ring_radius = drag_dist/2 * launch_timer.time_left / launch_timer.wait_time
	draw_circle(ball.position, ring_radius, drag_color, false, Global.line_width, anti_alias)
	
	# others: ball, flag, par, score
	if not show_title:
		draw_circle(ball.position, ball.radius, ball.color, true, -1.0, anti_alias)
		draw_flag()
		#draw_text('Par: ' + str(Global.par), par_text_pos, Global.default_text_height, ball.color)
		#if draw_hole_text:
			#hole_text_width = draw_text(hole_text, hole_text_pos, Global.default_text_height, ball.color)
	else:
		# title banner
		draw_rect(title_banner, banner_color, true, -1.0, false)
		var amplitude: float = .5
		var frequency: float = 1
		var seconds: float = Time.get_ticks_msec() * 0.001
		var base_x: float = (Global.game_width - title_width) / 2
		var base_y: float = title_banner.position.y + Global.default_text_height / 2
		var offset_x: float = cos(seconds * frequency) * amplitude
		var offset_y: float = sin(seconds * frequency) * amplitude
		title_pos = Vector2(base_x + offset_x, base_y + offset_y)
		title_width = draw_text('SPACE GOLF 2D', title_pos)
		
		# subtitle
		draw_rect(subtitle_banner, banner_color, true, -1.0, false)
		base_x = (Global.game_width - subtitle_width) / 2
		base_y = subtitle_banner.position.y + Global.default_text_height / 2
		offset_x = 2 * cos(seconds * frequency) * amplitude
		offset_y = 2 * sin(seconds * frequency) * amplitude
		subtitle_pos = Vector2(base_x - offset_x, base_y - offset_y)
		subtitle_color = Color.from_hsv(fmod(Time.get_ticks_msec(), 10000)/10000, 1, 1)
		subtitle_width = draw_text('SWIPE to begin!', subtitle_pos, Global.default_text_height / 2, subtitle_color)
