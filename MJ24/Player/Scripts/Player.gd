extends CharacterBody2D

# Export Variables ---------------
@export var projectile = preload("res://Player/Scenes/Projectiles/Projectile.tscn")

# on ready Variables -------------
@onready var sprite2D = $Sprite2D
@onready var gun_pivot = $GunPivot

# Variables ----------------------
var max_health = 100
var health = 100
var speed = 300.0
var direction = 0

# Physics Process ----------------
func _physics_process(delta):
	
	# Get the input direction and set states accordingly
	direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction: 
		$StateChart.send_event("movement_entered") # sets player to run state
	else:
		$StateChart.send_event("idle_entered") # sets player to idle state
	
	# Flip player sprite according to mouse location
	var mouse_pos = get_local_mouse_position().x
	if mouse_pos < 0:
		sprite2D.flip_h = true
	elif mouse_pos > 0:
		sprite2D.flip_h = false
		
	if Input.is_action_just_pressed("Fire_Weapon"):
		fire_weapon()
	
	gun_pivot.look_at(get_global_mouse_position())

# STATES --------------------------
# Idle State
func _on_idle_state_processing(delta): # on Idle State Entered
	velocity.x = move_toward(velocity.x, 0, speed) #Speed set to 0 for X
	velocity.y = move_toward(velocity.y, 0, speed) #Speed set to 0 for Y
	
	move_and_slide()
	
# Run State
func _on_run_state_processing(delta): #On Run State Entered
	velocity = direction * speed #change Speed
	
	move_and_slide()

# Functions -----------------------

func fire_weapon():
	var projectile_instance = projectile.instantiate()
	get_parent().add_child(projectile_instance)
	projectile_instance.transform = $GunPivot/Sprite2D/ProjectileSpawn.global_transform
