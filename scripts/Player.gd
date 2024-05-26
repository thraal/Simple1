extends CharacterBody2D

signal shoot_bullet(position: Vector2)

var speed: float = 200.0

func _ready() -> void:
	collision_layer = 1  # Layer  1
	collision_mask = 4   # Collide with layer 4 (enemies)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# Rotate enemy
		var target_position = get_viewport().get_mouse_position()
		var direction = (target_position - position).normalized()

		self.rotation = atan2(direction.y, direction.x) + PI/2

		# Spawn bullet
		emit_signal("shoot_bullet", self.get_node("ShootPoint").global_position)

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1

	velocity.x = direction.x * speed

	move_and_slide()

	# Clamp the player's position within the viewport bounds
	var viewport = get_viewport_rect()
	position.x = clamp(position.x, 0, viewport.size.x)
