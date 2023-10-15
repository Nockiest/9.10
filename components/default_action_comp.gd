extends Area2D
class_name DefaultAttackComponent
signal remain_actions_updated(new_attacks)
signal entering_action_state()
signal exiting_action_state()
var base_actions:int = 1
var remain_actions: int = base_actions:
	set(new_attacks):
		remain_actions = new_attacks
		emit_signal("remain_actions_updated", remain_actions)
var units_in_action_range:Array= []
var base_action_range:int = 100:
	set(value):
		base_action_range = value
		action_range =floor( base_action_range * Utils.sum_dict_values(aciton_range_modifiers))
var action_range:int = base_action_range:
	get:
		return action_range
	set(value):
		action_range = value
		units_in_action_range = []
		$AttackRangeShape.shape = CircleShape2D.new()
		$AttackRangeShape.shape.radius = action_range
		$AttackRangeCircle.queue_redraw() 
 
var aciton_range_modifiers = {
	"base_modifier": 1,
	"observer": 0
	}
var center
@export var highlight_color = "white"
enum States {
	Idle,
	TakingAction
}
var current_state = States.Idle
  
 
func enter_action_state():
	print("ENTERING ACTION STATE")
	entering_action_state.emit()
	current_state = States.TakingAction
	Globals.action_taking_unit = owner
	highlight_units_in_range()
	Globals.attacking_component = self
	$AttackRangeCircle.show()
func exit_action_state():
	print("EXITING ACTION STATE")
	exiting_action_state.emit()
	unhighlight_units_in_range()
	current_state = States.Idle
	Globals.action_taking_unit = null
	Globals.attacking_component = null
	$AttackRangeCircle.hide()

func update_from_observer_boost():
	action_range = base_action_range * Utils.sum_dict_values(aciton_range_modifiers)
	print("NEW ACTION RANGE", action_range)


func try_attack( ):
	print("processing", Globals.hovered_unit,Globals.action_taking_unit  )
	if !check_can_attack():
		exit_action_state()
		print("FAILED ",self, self.get_parent(),  check_can_attack() )
		return  "FAILED"
	if not Globals.hovered_unit in units_in_action_range:
		print_debug(2)
		return "FAILED"
	## I will add this to the try_attack component later too
#	print("TOGGLING")
#	toggle_action_screen()
	attack()
	return "SUCESS"

## ranged attack has an overide for this function  
func attack():
	Globals.last_attacker = owner
	exit_action_state()

func check_can_attack():
	print("GLOBALS ", Globals.action_taking_unit, owner, Globals.action_taking_unit == owner )
	if  Globals.action_taking_unit != owner:
		print_debug(1, Globals.action_taking_unit)
		return false
	if not Globals.hovered_unit:
		print_debug(2,   Globals.hovered_unit)
		return false
	if Globals.hovered_unit.color == owner.color:
		print_debug(3,  Globals.hovered_unit.color , owner.color)
		return false
	if remain_actions <= 0:
		print_debug(4,  remain_actions)
		return false
	print_debug(5)
	return true

func _ready():
	$AttackRangeCircle.hide()
	pass
 
func  update_for_next_turn():
	remain_actions = base_actions
	unhighlight_units_in_range()

func _process(_delta): 
	if "color" in owner:
		if Color(Globals.cur_player) != owner.color:
			return
	if current_state == States.Idle:
		if Input.is_action_just_pressed("right_click"):
			toggle_action_screen()
	elif current_state == States.TakingAction:
		if Input.is_action_just_pressed("right_click") :
			owner.process_action()
#			toggle_action_screen()
		elif Input.is_action_just_pressed("left_click"):
			exit_action_state()
  
func toggle_action_screen():
	if Globals.action_taking_unit == owner:
		exit_action_state()
		print_debug("1 ", self)
		return
	if Globals.hovered_unit != owner:
		print_debug ("2 ", self,  Globals.hovered_unit)
		return
	if Globals.action_taking_unit != null:
		print_debug("3 ", self,  Globals.action_taking_unit)
		return
	## switch between moving and doing action
#	owner.deselect_movement()
	if remain_actions > 0:
		enter_action_state()
#		Globals.action_taking_unit = owner
#		highlight_units_in_range()
#		Globals.attacking_component = self
	print("ACTION TAKING UNIT", Globals.action_taking_unit)
 
func highlight_units_in_range(): 
	print("HIGHLIGHTING UNITS", units_in_action_range)
	for unit in units_in_action_range:
		unit.get_node("ColorRect").modulate = Color(highlight_color)
 
func unhighlight_units_in_range():
	for enemy in units_in_action_range:
		enemy.get_node("ColorRect").modulate = enemy.color

func _on_area_entered(area):
 
	if area.get_parent() == owner:
#		print_debug("FAIL")
		return 2
	if area.name != "CollisionArea": 
#		print_debug("isnt unit", area.name)
		return 3
	if  area.get_parent().color == null:
#		print_debug("FAIL")
		return 5
	if area.get_parent().color == owner.color:
#		print_debug("ISNT SAME COLOR",area.get_parent().color , owner.color )
		return "SAME COLOR"
	units_in_action_range.append(area.get_parent())
	return 6


#func process_action():
#	print("CHILDReN OF THIS COMPONENT SHOULd HAVE ATTACK IN THEM")

func _on_area_exited(area):
	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
		units_in_action_range.erase(area.get_parent()) 
 


#    def find_obstacles_in_line_to_enemies(self, enemy, line_points):
#        # I could only reset the line to that specific unit instead of deleting the whole array
#        ######################### x FIND BLOCKING UNITS ##############
#        blocked = False
#        for unit in game_state.living_units.array:
#            if unit == enemy:
#                continue
#            elif unit.color == self.color:
#                continue
#            point_x, point_y, interferes = check_precalculated_line_square_interference(
#                unit, line_points)
#            distance_between_units = get_two_units_center_distance(unit  , enemy )
#
#            if interferes and abs(distance_between_units )> max(enemy.size//2, unit.size//2):
#                print("this unit is blocking the way", unit, enemy)
#                blocked = True
#                self.lines_to_enemies_in_range.append({
#                    "enemy": enemy,
#                    "start": self.center,
#                    "interference_point": (point_x, point_y),
#                    "end": enemy.center})
#
#                break
#        if not blocked:
#            self.lines_to_enemies_in_range.append({
#                "enemy": enemy,
#                "start": self.center,
#                "interference_point": None,
#                "end": enemy.center})
#
#        return blocked
#
  
#    def draw_lines_to_enemies_in_range(self):
#        for line in self.lines_to_enemies_in_range:
#            start = line["start"]
#            end = line["end"]
#            interference_point = line["interference_point"]
#
#            if interference_point is not None:
#                pygame.draw.line(screen, DARK_RED, start,
#                                 interference_point, 3)
#                pygame.draw.line(screen, (HOUSE_PURPLE),
#                                 interference_point, end, 3)
#            else:
#                pygame.draw.line(screen, DARK_RED, start, end, 3)
#                midpoint = ((start[0] + end[0]) // 2,
#                            (start[1] + end[1]) // 2)
#                distance = math.sqrt(
#                    (start[0] - end[0]) ** 2 + (start[1] - end[1]) ** 2)
#                font = pygame.font.Font(None, 20)
#                text_surface = font.render(
#                    f"{int(distance)} meters", True, WHITE)
#                text_rect = text_surface.get_rect(center=midpoint)
#                screen.blit(text_surface, text_rect)
# 
 
