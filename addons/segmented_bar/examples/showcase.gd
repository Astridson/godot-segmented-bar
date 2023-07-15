extends Control

var max_health := 10.0
var health := 10.0

var bars: Array[Bar] = []
@onready var hp_label := %Label as Label

func _ready():
	_set_label()
	hp_label.modulate = Color.PALE_VIOLET_RED
	for b in %Bars.get_children():
		bars.append(b) #Hack for Array[Node] -> Array[Bar]

	for bar in bars:
		bar.set_health(health)
		bar.set_max_health(max_health)


func _on_damage_pressed() -> void:
	health = maxf(0, health - 3.0)
	_set_label()
	for bar in bars:
		bar.damage(health)


func _on_heal_pressed() -> void:
	health = minf(max_health, health + 3.0)
	_set_label()
	for bar in bars:
		bar.heal(health)


func _on_heal_full_pressed() -> void:
	health = max_health
	_set_label()
	for bar in bars:
		bar.set_health(health)


func _on_increase_max_pressed() -> void:
	max_health += 1.0
	_set_label()
	for bar in bars:
		bar.set_max_health(max_health)


func _set_label():
	hp_label.text = "HP: %d/%d" % [health, max_health]
	var tween := create_tween()
	tween.tween_property(hp_label, "modulate", Color.WHITE, 0.05)
	tween.tween_property(hp_label, "modulate", Color.PALE_VIOLET_RED, 0.05)
