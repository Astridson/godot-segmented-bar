@tool
@icon("res://addons/segmented_bar/assets/icon.png")
class_name SegmentedBar extends HBoxContainer


@export var foreground_color := Color.DARK_RED:
	set(value):
		foreground_color = value
		_update_segments()


@export var background_color := Color.DARK_GRAY:
	set(value):
		background_color = value
		_update_segments()


var change_color := Color.GHOST_WHITE


@export var max_value := 1.0
@export var value := 0.5


@export var segment_texture: Texture = preload("res://addons/segmented_bar/assets/pixel.png"):
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


var percent := 0.5
var display_percent := 0.5
var change_rate := 1.0

var hanging_tween: Tween
var flashing_tween: Tween
var hanging := false
var flashing := false
var segments: Array[TextureRect] = []


func _ready() -> void:
	segment_texture = segment_texture
	seperation = seperation
	percent = value / max_value
	_update_segments()


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if flashing:
			return
		if display_percent < percent:
			display_percent = minf(percent, display_percent + change_rate * delta)
			_update_segments()
		elif display_percent > percent:
			display_percent = maxf(percent, display_percent - change_rate * delta)
			_update_segments()


func set_value(new_value: float) -> void:
	value = new_value
	percent = value / max_value
	display_percent = percent
	_update_segments()


func set_max(new_max: float) -> void:
	max_value = new_max
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


func _update_segments() -> void:
	var size: float = segments.size()

	for s in range(size):
		var segment_frac := s / size
		var segment := segments[s] as TextureRect
		if segment_frac < display_percent and segment_frac < percent:
			segment.modulate = foreground_color
		elif segment_frac >= display_percent and segment_frac >= percent:
			segment.modulate = background_color
		else:
			segment.modulate = change_color


func _end_flash() -> void:
	flashing = false
	_update_segments()


func _exit_tree() -> void:
	if hanging_tween != null:
		hanging_tween.kill()

	if flashing_tween != null:
		flashing_tween.kill()
