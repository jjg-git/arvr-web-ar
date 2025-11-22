extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mobile_direction: Vector2 = Vector2.ZERO
@onready var start_position: Vector3 = position

func _ready() -> void:
	%VirtualController.send_direction.connect(func(dir): mobile_direction = dir)

func _process(delta: float) -> void:
	if position.y < -5.0:
		position = start_position
	
	if not %VirtualController/Joystick.visible:
		mobile_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var camera = $XROrigin3D/XRCamera3D
	var camera_transform:Transform3D = transform * camera.transform
	
	var new_position := camera_transform.origin * Vector3(1.0, 0.0, 1.0)
	var original_position := global_position
		
	var input_dir := Vector2.ZERO
	
	if get_viewport().use_xr:
		input_dir = mobile_direction
	else:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	var delta_movement = global_position - original_position
	delta_movement = global_basis.inverse() * delta_movement
	position -= delta_movement
