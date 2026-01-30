/obj/effect/map_entity/cart_detector
	name = "cart_detector"
	icon_state = "trigger"
	is_brush = TRUE
	var/filter_faction = null

/obj/effect/map_entity/cart_detector/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!istype(AM, /obj/structure/payload))
		return
	
	if(filter_faction)
		var/obj/structure/payload/P = AM
		if(P.warfare_faction != filter_faction)
			return

	fire_output("OnTrigger", AM, src)

/obj/effect/map_entity/cart_detector/Uncrossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!istype(AM, /obj/structure/payload))
		return
		
	if(filter_faction)
		var/obj/structure/payload/P = AM
		if(P.warfare_faction != filter_faction)
			return

	fire_output("OnTriggerEnd", AM, src)

/obj/effect/map_entity/cart_detector/red
	name = "cart_detector_red"
	filter_faction = RED_TEAM

/obj/effect/map_entity/cart_detector/blue
	name = "cart_detector_blue"
	filter_faction = BLUE_TEAM

/obj/effect/map_entity/cart_teleport
	name = "cart_teleport"
	icon_state = "oneway"
	var/teleport_target = ""
	var/auto_movement_distance = 0
	var/auto_move_time = 1 SECOND

/obj/effect/map_entity/cart_teleport/proc/do_teleport(obj/structure/payload/P)
	if(!istype(P)) return

	var/atom/target = null
	
	var/list/targets = find_io_targets(teleport_target)
	if(length(targets))
		target = targets[1]
	
	if(!target)
		return

	P.forceMove(get_turf(target))
	
	if(istype(target, /obj/structure/track))
		var/obj/structure/track/T = target
		P.current_track = T
		P.dir = T.dir
		P.current_angle = T.angle
		P.apply_rotation(P.current_angle)
	else
		P.dir = target.dir
		P.current_angle = dir2angle(target.dir)
		P.apply_rotation(P.current_angle)
	
	fire_output("OnTeleport", P, src)

	if(auto_movement_distance > 0)
		spawn(0)
			perform_auto_movement(P)

/obj/effect/map_entity/cart_teleport/proc/perform_auto_movement(obj/structure/payload/P)
	P.move_override = TRUE
	
	var/turf/start_T = get_turf(P)
	var/turf/end_T = start_T
	
	for(var/i in 1 to auto_movement_distance)
		end_T = get_step(end_T, P.dir)
		if(!end_T)
			end_T = get_step(end_T, turn(P.dir, 180))
			break

	if(!end_T || end_T == start_T)
		P.move_override = FALSE
		return
	
	var/pix_x = (end_T.x - start_T.x) * 32
	var/pix_y = (end_T.y - start_T.y) * 32
	
	animate(P, pixel_x = pix_x, pixel_y = pix_y, time = auto_move_time, easing = SINE_EASING)
	
	sleep(auto_move_time)
	
	if(P && !QDELETED(P))
		P.forceMove(end_T)
		P.pixel_x = 0
		P.pixel_y = 0
		
		var/obj/structure/track/T = locate() in end_T
		if(T)
			P.current_track = T
			P.current_angle = T.angle
		
		P.move_override = FALSE

/*
Inputs:
Teleport - Teleports the activator (or payload in similiar tile) to target

Outputs:
OnTeleport - Fired when teleport is successful
*/
/obj/effect/map_entity/cart_teleport/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.) return TRUE

	if(lowertext(input_name) == "teleport")
		var/obj/structure/payload/P = activator
		
		if(!istype(P))
			P = locate() in get_turf(src)
			
		if(P)
			do_teleport(P)
		return TRUE
	
	return FALSE
