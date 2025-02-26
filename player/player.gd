class_name Player
extends CharacterBody2D


signal player_has_shot(bullets: Array)
signal health_changed(new_health: float)

@export var speed: float
@export var max_health: float

@onready var attack_cooldown: Timer = $AttackCooldown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet: PackedScene = preload("res://bullets & projectiles/bullet.tscn")

@onready var arsenal = Guns.new()
@onready var gun: Gun = arsenal.sniper	

@onready var health: float = max_health:
	set(new_value):
		health = new_value
		emit_signal("health_changed", (health / max_health) * 100)

@onready var direction: Vector2 = Vector2.ZERO


func _physics_process(delta: float):
	velocity = direction.normalized() * speed
	
	move_and_slide()
	
	look_at(get_global_mouse_position())
	
	if Input.is_key_pressed(KEY_1):
		gun = arsenal.pistol
	elif Input.is_key_pressed(KEY_2):
		gun = arsenal.assault_rifle
	elif Input.is_key_pressed(KEY_3):
		gun = arsenal.shotgun
	elif Input.is_key_pressed(KEY_4):
		gun = arsenal.sniper
	
	if Input.is_action_pressed("shoot"):
		shoot()


func _input(event):
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)


func shoot():
	emit_signal(
		"player_has_shot",
		gun.shoot(position, rotation, bullet, attack_cooldown, animated_sprite)
	)


func _on_animation_finished():
	gun.reset_animation(animated_sprite)


func handle_enemy_attack(damage: float):
	health -= damage
	
	if health <= 0:
		get_tree().change_scene_to_file("res://ui/menus/game_over_menu.tscn")
