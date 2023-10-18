class_name RiverSegment
extends Node2D
signal intersects_another_river(this, colliding_area)
 
func _on_area_2d_area_entered(area):
 
	if  area.get_parent().get_parent().get_parent()  == get_parent().get_parent():
		return
	if area.is_in_group("river_segment_collision_shapes"):
		emit_signal("intersects_another_river", self, area)
