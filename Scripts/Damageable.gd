extends Node3D

class_name Damageable

@export var maxHealth : float
@export var customDeathEffect : PackedScene
@export_enum("PlayerUI", "Floating", "BossBar", "None") var HealthBarType : int = 1
@export var floatingDist : float = 1.0

var floating_handler = null

var redPart = null
var darkRedPart = null
var healthLabel = null

var health : float = 0.0
var barSize : float = 0.0

@onready var parent = get_parent()
@onready var player = get_parent().get_parent().get_child(0)

signal damageTaken

# Called when the node enters the scene tree for the first time.
func _ready():
	health = maxHealth
	
	match HealthBarType:
		0: #Player UI
			redPart = $PlayerUIMode/redBar
			darkRedPart = $PlayerUIMode/darkRedBar
			healthLabel = $PlayerUIMode/Label
			$FloatingMode.queue_free()
		1: #Floating Mode
			redPart = $FloatingMode/redBat
			darkRedPart = $FloatingMode/darkRedBar
			healthLabel = $FloatingMode/Label3D
			floating_handler = $FloatingMode
			$PlayerUIMode.queue_free()
	
	
	
	
	call_deferred("_updateHealthBar")

func _updateHealthBar():
	healthLabel.text = "Hp: " + str(health) + " / " + str(maxHealth)
	
	#get the percentage of health / maxhealth
	var percantage : float = health / maxHealth
	#if the health is 0 percantage should be 0
	if health <= 0.0:
		percantage = 0.0
	var maxSize : float = 245.0
	#change the size of the rect relative to the percantage
	barSize = percantage * maxSize
	var redTween = create_tween()
	var darkRedTween = create_tween()
	
	if barSize < 1:
		redPart.visible = false
		darkRedPart.visible = false
		return

func _damage(damage : float):
	health -= damage
	health = clamp(health, 0, maxHealth)
	
	if health <= 0:
		_death()
	
	damageTaken.emit()
	_updateHealthBar()

func _death():
	if customDeathEffect:
		var inst = customDeathEffect.instantiate()
		parent.add_child(inst)
	
	if not parent is playerClass:
		parent.queue_free()
	else:
		get_tree().reload_current_scene()

func _process(delta):
	match HealthBarType:
		1:
			floating_handler.global_position.x = global_position.x
			floating_handler.global_position.y = global_position.y + floatingDist
			floating_handler.global_position.z = global_position.z
			
			if global_position.distance_to(player.global_position) > 7:
				floating_handler.visible = false
			else:
				floating_handler.visible = true
	
	if redPart is TextureRect:
		redPart.size = lerp(redPart.size, Vector2(barSize, 36.0), 4.0 * delta)
		darkRedPart.size = lerp(darkRedPart.size, Vector2(barSize, 36.0), 2.0 * delta)
	else:
		redPart.texture.width = lerp(float(redPart.texture.width), barSize, 4.0 * delta)
		darkRedPart.texture.width = lerp(float(darkRedPart.texture.width), barSize, 2.0 * delta)
	
	
