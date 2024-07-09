extends CharacterBody2D

# Export Variables ---------------
@export var projectile = preload("res://Player/Scenes/Projectiles/Projectile.tscn")

# on ready Variables -------------
@onready var sprite2D = $Sprite2D
@onready var gun_pivot = $GunPivot_Right
@onready var reload_timer = $ReloadTimer

# Variables ----------------------
# Stats
var is_alive = true
var max_health = 100
var health = 100
var speed = 300.0
var reloading = false
var max_ammo = 10
var ammo = 10

# Singletons
var direction = 0
var mouse_pos = 0

func _process(_delta):
	
	# Health Check
	if health <= 0 and is_alive == true:
		$StateChart.send_event("death_entered") #enters death state

	if Input.is_action_just_pressed("ui_accept"): # THIS IS JUST FOR TESTING!!!!!!
		health = 0

	# get fire input and check ammo
	if Input.is_action_just_pressed("Fire_Weapon") and ammo > 0:
		fire_weapon()
	
	if Input.is_action_just_pressed("Fire_Weapon") and ammo <= 0 and reloading == false:
		reload_weapon()
		print("RELOADING")
		
# Physics Process ----------------
func _physics_process(_delta):
	
	# Get the input direction and set states accordingly
	direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction: 
		$StateChart.send_event("movement_entered") # sets player to run state
	else:
		$StateChart.send_event("idle_entered") # sets player to idle state
	
	# Flip player and gun sprite according to mouse location
	mouse_pos = get_local_mouse_position().x
	if mouse_pos < 0:
		sprite2D.flip_h = true
		gun_pivot.position.x = -3
		gun_pivot.scale.y = -1
	elif mouse_pos > 0:
		sprite2D.flip_h = false
		gun_pivot.position.x = 3
		gun_pivot.scale.y = 1
		
	# set projectile global rotation
	gun_pivot.look_at(get_global_mouse_position())

# STATES --------------------------
# Idle State
func _on_idle_state_processing(_delta): # on Idle State Entered
	velocity.x = move_toward(velocity.x, 0, speed) #Speed set to 0 for X
	velocity.y = move_toward(velocity.y, 0, speed) #Speed set to 0 for Y
	
	move_and_slide()
	
# Run State
func _on_run_state_processing(_delta): #On Run State Entered
	velocity = direction * speed #change Speed
	
	move_and_slide()
	
#Death State
func _on_death_state_processing(_delta):
	is_alive = false
	get_tree().change_scene_to_file("res://Main/Levels/Menus/DeathScreen.tscn")

# Functions -----------------------
# Spawn instance of projectile
func fire_weapon():
	ammo = ammo - 1
	var projectile_instance = projectile.instantiate()
	get_parent().add_child(projectile_instance)
	projectile_instance.transform = $GunPivot_Right/Sprite2D/ProjectileSpawn.global_transform

func reload_weapon():
	reloading = true
	reload_timer.start()

func _on_reload_timer_timeout():
	ammo = max_ammo
	reloading = false
