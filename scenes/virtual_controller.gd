extends Control

var tapped: bool = false
var tapped_position:Vector2 = Vector2.ZERO
var stick_origin:Vector2 = Vector2.ZERO
var direction:Vector2

signal send_direction(direction: Vector2)

func _process(_delta: float) -> void:
	#queue_redraw()
	if tapped:
		var offset = $Joystick/Stick.size/2
		var max_size = ($Joystick.size/2 - offset).length()
		var stick_position:Vector2 = (get_local_mouse_position() - $Joystick.position) - offset
		$Joystick/Stick.position = stick_origin + (stick_position - stick_origin).limit_length(max_size)
		
		direction = (stick_position - stick_origin).normalized()
		send_direction.emit(direction)

#func _draw() -> void:
	#if tapped:
		#draw_line(get_local_mouse_position(), tapped_position, Color.RED, 10)
		#draw_circle($Joystick.position + stick_origin, 10, Color.GREEN)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			tapped = event.pressed
			$Joystick.position = event.position - $Joystick.size/2
			$Joystick/Stick.position = $Joystick.size/2 - $Joystick/Stick.size/2
			
			tapped_position = event.position
			stick_origin = $Joystick/Stick.position
			print("stick_origin (", stick_origin, ")")
		else:
			tapped = false
		$Joystick.visible = event.pressed
	
