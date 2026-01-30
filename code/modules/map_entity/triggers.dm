/obj/effect/map_entity/trigger
	name = "trigger"
	icon_state = "trigger"
	is_brush = TRUE
	var/trigger_once = FALSE
	var/cooldown = 0
	var/last_trigger_time = 0
	var/filter_faction = null
	var/filter_living = TRUE
	var/list/filter_types = null
	var/list/entities_inside

	var/stay_while_occupied = FALSE

	var/conscious_only = FALSE

/obj/effect/map_entity/trigger/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled)
		return
	if(!can_trigger(AM))
		return
	
	var/is_new_entry = !(AM in entities_inside)
	if(is_new_entry)
		LAZYADD(entities_inside, AM)

	var/turf/prev_turf = get_step(AM,turn(AM.dir, 180))
	if(prev_turf)
		for(var/obj/effect/map_entity/trigger/T in prev_turf)
			if(T == src)
				continue
			if(T.is_brush && is_brush && T.name == name)
				if(T in brush_neighbors)
					return

	if(cooldown > 0 && (world.time - last_trigger_time) < cooldown)
		return

	last_trigger_time = world.time
	fire_output("OnTrigger", AM, src)
	if(trigger_once)
		qdel(src)

/obj/effect/map_entity/trigger/Uncrossed(atom/movable/AM)
	. = ..()
	if(!enabled || !(AM in entities_inside))
		return

	LAZYREMOVE(entities_inside, AM)

	var/turf/dest_turf = get_turf(AM)
	if(dest_turf)
		for(var/obj/effect/map_entity/trigger/T in dest_turf)
			if(T == src)
				continue
			if(T.is_brush && is_brush && T.name == name)
				if(T in brush_neighbors)
					return

	if(stay_while_occupied)
		if(count_valid_inside() > 0)
			return
			
	fire_output("OnTriggerEnd", AM, src)

/obj/effect/map_entity/trigger/proc/count_valid_inside()
	var/count = 0
	for(var/atom/movable/AM in entities_inside)
		if(can_trigger(AM))
			count++
	return count

/obj/effect/map_entity/trigger/proc/can_trigger(atom/movable/AM)
	if(filter_living && !isliving(AM))
		return FALSE

	if(conscious_only && isliving(AM))
		var/mob/living/L = AM
		if(L.stat != CONSCIOUS)
			return FALSE

	if(filter_faction)
		var/mob/M = AM
		if(!istype(M) || M.warfare_faction != filter_faction)
			return FALSE

	if(filter_types?.len)
		for(var/T in filter_types)
			if(istype(AM, T))
				return TRUE
		return FALSE
	return TRUE

/*
Inputs:
Trigger - Manually triggers the entity
Toggle - Toggles the enabled state

Outputs:
OnTrigger - Fired when an entity enters or is manually triggered
OnTriggerEnd - Fired when an entity leaves
*/
/obj/effect/map_entity/trigger/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("trigger")
			fire_output("OnTrigger", activator, caller)
			if(trigger_once)
				qdel(src)
			return TRUE
		if("toggle")
			enabled = !enabled
			return TRUE
	return FALSE

/obj/effect/map_entity/trigger/once
	name = "trigger_once"
	trigger_once = TRUE

/obj/effect/map_entity/trigger/multiple
	name = "trigger_multiple"
	trigger_once = FALSE
	cooldown = 0

/obj/effect/map_entity/trigger/faction/red
	name = "trigger_red"
	filter_faction = RED_TEAM

/obj/effect/map_entity/trigger/faction/blue
	name = "trigger_blue"
	filter_faction = BLUE_TEAM

/obj/effect/map_entity/trigger/faction/toggle
	name = "trigger_toggle"
	filter_faction = RED_TEAM

/*
Inputs:
Toggle - Toggles the required faction between RED and BLUE
*/
/obj/effect/map_entity/trigger/faction/toggle/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	
	switch(lowertext(input_name))
		if("toggle")
			if(filter_faction == RED_TEAM)
				filter_faction = BLUE_TEAM
			else
				filter_faction = RED_TEAM
			return TRUE
	return FALSE

/obj/effect/map_entity/trigger/hurt
	name = "trigger_hurt"
	icon_state = "trigger_hurt"
	var/damage = 10
	var/damage_type = BRUTE

/obj/effect/map_entity/trigger/hurt/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !isliving(AM))
		return
	var/mob/living/L = AM
	switch(damage_type)
		if(BRUTE)
			L.adjustBruteLoss(damage)
		if(BURN)
			L.adjustFireLoss(damage)
		if(OXY)
			L.adjustOxyLoss(damage)
		if(TOX)
			L.adjustToxLoss(damage)
	to_chat(L, SPAN_DANGER("I've been hurt by something!"))

/obj/effect/map_entity/trigger/push
	name = "trigger_push"
	icon_state = "trigger_push"
	var/push_dir = NORTH
	var/push_speed = 1

/obj/effect/map_entity/trigger/push/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !isliving(AM))
		return
	var/mob/living/L = AM
	for(var/i = 1 to push_speed)
		step(L, push_dir)
