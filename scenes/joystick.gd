@tool
extends Control

func _process(float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(size/2, size.x/2, Color.from_rgba8(255, 255, 255, 256 * 0.20), true)
