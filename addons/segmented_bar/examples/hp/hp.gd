extends Bar

@export var damage_color: Color

@onready var segmented_bar := %SegmentedBar as SegmentedBar


func set_health(health: float):
	segmented_bar.set_value(health)


func set_max_health(max_health: float):
	segmented_bar.set_max(max_health)


func damage(new_health: float) -> void:
	segmented_bar.flash(0.1, Color.WHITE)
	segmented_bar.change_rate = 0.5
	segmented_bar.slow_change(new_health, damage_color, 0.8)


func heal(new_health: float) -> void:
	segmented_bar.change_rate = 1000.0
	segmented_bar.slow_change(new_health, Color.TRANSPARENT, 0.0)
