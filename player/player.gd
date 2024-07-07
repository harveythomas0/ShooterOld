class_name Player
extends CharacterBody2D


signal player_has_shot(bullet: PackedScene, position: Vector2, rotation: float)
signal health_changed(new_health: float)

@export var speed: float
@export var max_health: float

@onready var shoot_marker: Marker2D = $ShootMarker
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_manager: Node2D = get_parent().get_node("BulletManager")
@onready var bullet: PackedScene = preload("res://bullets & projectiles/bullet.tscn")

@onready var health: float = max_health:
	set(new_value):
		health = new_value
		emit_signal("health_changed", (health / max_health) * 100)

var assault_rifle: Gun = Gun.new(10, 1, 1, 3, 500)


func _physics_process(delta: float):
	var direction: Vector2 = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	)
	
	velocity = direction.normalized() * speed
	
	move_and_slide()
	
	look_at(get_global_mouse_position())


func _process(delta: float):
	if Input.is_action_pressed("shoot"):
		shoot()


func shoot():
	var has_shot: bool = assault_rifle.shoot(shoot_marker.global_position, rotation, bullet, bullet_manager, attack_cooldown)
	
	if has_shot:
		animated_sprite.play("shoot")
	
	#if attack_cooldown.is_stopped():
		#animated_sprite.play("shoot")
		#var new_bullet: Bullet = bullet.instantiate()
		#emit_signal("player_has_shot", new_bullet, shoot_marker.global_position, rotation)
		#attack_cooldown.start()


func _on_animation_finished():
	if animated_sprite.animation == "shoot":
		animated_sprite.play("default")


func handle_enemy_attack(damage: float):
	health -= damage
	
	if health <= 0:
		get_tree().change_scene_to_file("res://ui/menus/game_over_menu.tscn")
