extends Control

@onready var correct_button : Button = $Button
@onready var incorrect_button : Button = $Button2
@onready var levelSwitcher : LevelManager = get_parent().get_node("LevelManager")
@export var level : PackedScene



func _on_button_pressed() -> void:
	queue_free()
	levelSwitcher._switch_level(level)


func _on_button_2_pressed() -> void:
	get_tree().quit()
