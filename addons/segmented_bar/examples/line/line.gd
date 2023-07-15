extends Bar

@export var damage_color: Color
@export var heal_color: Color

@onready var segmented_bar := $SegmentedBar as SegmentedBar


func set_health(health: float) -> void:
	segmented_bar.set_value(health)


func set_max_health(max_health: float) -> void:
	segmented_bar.set_max(max_health)


func heal(health: float) -> void:
	segmented_bar.change_rate = 0.1
	segmented_bar.slow_change(health, heal_color, 0.0)


func damage(health: float) -> void:
	segmented_bar.flash(0.03, Color.WHITE)
	segmented_bar.change_rate = 0.1
	segmented_bar.slow_change(health, damage_color, 2.0)
