@tool
extends Control

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(size/2, size.x/2, Color.from_rgba8(255, 255, 0, 256 * 0.50), true)
