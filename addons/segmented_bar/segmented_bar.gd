@tool
@icon("res://addons/segmented_bar/assets/icon.png")
class_name SegmentedBar extends HBoxContainer

signal bar_value_changed(new_value: float)
signal max_value_changed(new_value: float)

@export var foreground_color := Color.DARK_RED:
	set(value):
		
		foreground_color = value
		_update_segments(1)


@export var background_color := Color.DARK_GRAY:
	set(value):
		background_color = value
		_update_segments(1)


var change_color := Color.GHOST_WHITE


@export var max_value: float = 1.0: set = set_max

@export var value: float = 0.5: set = set_value


@export var segment_texture: Texture:
	set(value):
		segment_texture = value
		_create_segments()

@export var total_segments := 10:
	set(value):
		total_segments = value
		_create_segments()


@export var seperation := 1:
	set(value):
		seperation = value
		set("theme_override_constants/separation", seperation)

@export_group("Fading")

@export var fading_enabled: bool = false

@export var segment_fade_time: float = 0.1

@export var delay: float = 0.05

var percent := 0.5
var display_percent := 0.5
var change_rate := 1.0

var fading_tweens: Array = []
var hanging_tween: Tween
var flashing_tween: Tween
var hanging := false
var flashing := false
var segments: Array[TextureRect] = []


func _ready() -> void:
	segment_texture = segment_texture
	seperation = seperation
	percent = value / max_value
	_create_segments()


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if flashing:
			return
		if display_percent < percent:
			display_percent = minf(percent, display_percent + change_rate * delta)
			_update_segments(1)
		elif display_percent > percent:
			display_percent = maxf(percent, display_percent - change_rate * delta)
			_update_segments(1)


func set_value(new_value: float) -> void:
	var old_value = value
	if new_value > max_value: #caps value to max_value
		new_value = max_value
	if new_value == value: #keeps _update_segments() from being called if nothing has changed
		return
	value = new_value
	emit_signal("bar_value_changed", new_value)
	percent = value / max_value
	display_percent = percent
	_update_segments(1 if new_value > old_value else -1)


func set_max(new_max: float) -> void:
	if new_max < value: #caps value to max_value
		value = new_max
	if new_max == max_value: #keeps _update_segments() from being called if nothing has changed
		return
	max_value = new_max
	emit_signal("max_value_changed", new_max)
	percent = value / max_value
	display_percent = percent
	_update_segments()


func slow_change(new_value: float, color: Color, hang_time: float) -> void:
	value = new_value
	var new_percent := new_value / max_value
	hanging = true
	change_color = color
	if (percent < display_percent and new_percent > percent) or (percent > display_percent and new_percent < percent):
		display_percent = percent

	percent = new_percent
	
	if hanging_tween != null:
		hanging_tween.kill()
	hanging_tween = create_tween()
	hanging_tween.tween_callback(func(): hanging = false).set_delay(hang_time)


func flash(time: float, color: Color) -> void:
	flashing = true

	for s in segments:
		s.modulate = color
	
		
	if flashing_tween != null:
		flashing_tween.kill()
	flashing_tween = create_tween()
	flashing_tween.tween_callback(_end_flash).set_delay(time)

func _create_segments() -> void:
	for s in segments:
		s.free()
	
	segments.clear()
	if segment_texture != null:
		for i in range(total_segments):
			var s := TextureRect.new()
			s.texture = segment_texture
			segments.append(s)
			add_child(s)
	
	_update_segments()


func _update_segments(update_direction: int = 0) -> void: #-1 means update from right to left, +1 is the opposite
	var size: float = segments.size()
	
	#These variables are here for fading. This helps create a "wave" effect on quick transitions.
	var set_bg_color = background_color
	var set_fg_color = foreground_color
	
	if update_direction < 0:
		for s in range(size - 1, -1, -1):
			var segment_frac := s / size
			var segment := segments[s] as TextureRect
			if segment_frac < display_percent and segment_frac < percent:
				segment.modulate = foreground_color
			elif segment_frac >= display_percent and segment_frac >= percent:
				if fading_enabled && update_direction != 0:
					var tween = get_tree().create_tween()
					var tween_timer = get_tree().create_timer(delay)
					tween.tween_property(segment, "modulate", set_bg_color, segment_fade_time)
					await tween_timer.timeout
				else:
					segment.modulate = background_color
			else:
				segment.modulate = change_color
	else:
		for s in range(size):
			var segment_frac := s / size
			var segment := segments[s] as TextureRect
			if segment_frac < display_percent and segment_frac < percent:
				if fading_enabled && update_direction != 0:
					var tween = get_tree().create_tween()
					var tween_timer = get_tree().create_timer(delay)
					tween.tween_property(segment, "modulate", set_fg_color, segment_fade_time)
					await tween_timer.timeout
				else:
					segment.modulate = foreground_color
			elif segment_frac >= display_percent and segment_frac >= percent:
				segment.modulate = background_color
			else:
				segment.modulate = change_color

func _set_segment_color(seg: int, size: int):
		var segment_frac := seg / size
		var segment := segments[seg] as TextureRect
		if segment_frac < display_percent and segment_frac < percent:
			segment.modulate = foreground_color
		elif segment_frac >= display_percent and segment_frac >= percent:
			if fading_enabled:
				var tween = get_tree().create_tween()
				var tween_timer = get_tree().create_timer(delay)
				tween.tween_property(segment, "modulate", background_color, segment_fade_time)
				await tween_timer.timeout
			else:
				segment.modulate = background_color
		else:
			segment.modulate = change_color



func _end_flash() -> void:
	flashing = false
	_update_segments(1)


func _exit_tree() -> void:
	if hanging_tween != null:
		hanging_tween.kill()

	if flashing_tween != null:
		flashing_tween.kill()
