extends Control

class_name Damageable

@export var maxHealth : float

@onready var redPart : TextureRect = $redBar
@onready var darkRedPart : TextureRect = $darkRedBar
@onready var healthLabel : Label = $Label

var health : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth
	_updateHealthBar()

func _updateHealthBar():
	healthLabel.text = "Hp: " + str(health) + " / " + str(maxHealth)
	
	#get the percentage of health / maxhealth
	var percantage : float = health / maxHealth
	#if the health is 0 percantage should be 0
	if health <= 0.0:
		percantage = 0.0
	var maxSize : float = 245.0
	#change the size of the rect relative to the percantage
	var barSize : float = percantage * maxSize
	var redTween = create_tween()
	var darkRedTween = create_tween()
	redTween.tween_property(redPart, "size", Vector2(barSize, 36), 0.2)
	darkRedTween.tween_property(darkRedPart, "size", Vector2(barSize, 36), 0.4)

func _damage(damage : float):
	health -= damage
	_updateHealthBar()

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_Q:
			_damage(1.0)
		elif event.keycode == KEY_E:
			_damage(-1.0)
