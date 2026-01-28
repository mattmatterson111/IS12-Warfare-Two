// Logic entities for map scripting

// Logic Relay - receives Trigger, fires OnTrigger
/obj/effect/map_entity/logic_relay
	name = "logic_relay"
	icon_state = "logic_relay"
	var/trigger_once = FALSE
	var/cooldown = 0
	var/last_trigger_time = 0

/obj/effect/map_entity/logic_relay/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("trigger")
			if(cooldown > 0 && (world.time - last_trigger_time) < cooldown)
				return TRUE
			last_trigger_time = world.time
			fire_output("OnTrigger", activator, caller)
			if(trigger_once)
				qdel(src)
			return TRUE
	return FALSE

// Logic Counter - counts triggers, fires on threshold
/obj/effect/map_entity/logic_counter
	name = "logic_counter"
	icon_state = "math_counter"
	var/count = 0
	var/threshold = 3
	var/reset_on_threshold = TRUE

/obj/effect/map_entity/logic_counter/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("add", "increment")
			count++
			fire_output("OnCount", activator, caller)
			check_threshold(activator, caller)
			return TRUE
		if("subtract", "decrement")
			count--
			fire_output("OnCount", activator, caller)
			check_threshold(activator, caller)
			return TRUE
		if("reset")
			count = 0
			fire_output("OnReset", activator, caller)
			return TRUE
		if("setvalue")
			if(params?["value"])
				count = text2num(params["value"])
			return TRUE
	return FALSE

/obj/effect/map_entity/logic_counter/proc/check_threshold(atom/activator, atom/caller)
	if(count >= threshold)
		fire_output("OnThreshold", activator, caller)
		if(reset_on_threshold)
			count = 0

// Logic Timer - fires outputs on interval
/obj/effect/map_entity/logic_timer
	name = "logic_timer"
	icon_state = "logic_timer"
	var/interval = 10 SECONDS
	var/running = FALSE
	var/start_on_spawn = FALSE
	var/timer_id = null

/obj/effect/map_entity/logic_timer/Initialize()
	. = ..()
	if(start_on_spawn)
		start_timer()

/obj/effect/map_entity/logic_timer/Destroy()
	stop_timer()
	return ..()

/obj/effect/map_entity/logic_timer/proc/start_timer()
	if(running)
		return
	running = TRUE
	schedule_next()

/obj/effect/map_entity/logic_timer/proc/stop_timer()
	running = FALSE
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/obj/effect/map_entity/logic_timer/proc/schedule_next()
	if(!running)
		return
	timer_id = addtimer(CALLBACK(src, PROC_REF(timer_tick)), interval, TIMER_STOPPABLE)

/obj/effect/map_entity/logic_timer/proc/timer_tick()
	if(!running || !enabled)
		return
	fire_output("OnTimer", null, src)
	schedule_next()

/obj/effect/map_entity/logic_timer/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("start")
			start_timer()
			return TRUE
		if("stop")
			stop_timer()
			return TRUE
		if("toggle")
			if(running)
				stop_timer()
			else
				start_timer()
			return TRUE
		if("firenow")
			fire_output("OnTimer", activator, caller)
			return TRUE
	return FALSE

// Logic Case - fires different outputs based on value
/obj/effect/map_entity/logic_case
	name = "logic_case"
	icon_state = "logic_case"
	var/list/cases = list()  // "value" -> "OutputName"
	var/default_output = "OnDefault"

/obj/effect/map_entity/logic_case/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("invalue")
			var/value = params?["value"]
			if(value && cases[value])
				fire_output(cases[value], activator, caller)
			else if(default_output)
				fire_output(default_output, activator, caller)
			return TRUE
	return FALSE

// Logic Compare - compares values
/obj/effect/map_entity/logic_compare
	name = "logic_compare"
	icon_state = "logic_compare"
	var/compare_value = 0

/obj/effect/map_entity/logic_compare/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE

	switch(lowertext(input_name))
		if("compare")
			var/value = params ? text2num(params["value"]) : 0
			if(value > compare_value)
				fire_output("OnGreater", activator, caller)
			else if(value < compare_value)
				fire_output("OnLess", activator, caller)
			else
				fire_output("OnEqual", activator, caller)
			return TRUE
		if("setcompare")
			compare_value = params ? text2num(params["value"]) : 0
			return TRUE
	return FALSE

// Logic Auto - fires on round events (replaces round_events)
/obj/effect/map_entity/logic_auto
	name = "logic_auto"
	icon_state = "world_events"
	targetname = "game_events"

/obj/effect/map_entity/logic_auto/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("redteamwin")
			fire_output("OnRedTeamWin", activator, caller)
			fire_output("OnTeamWin", activator, caller)
			return TRUE
		if("blueteamwin")
			fire_output("OnBlueTeamWin", activator, caller)
			fire_output("OnTeamWin", activator, caller)
			return TRUE
		if("redteamlose")
			fire_output("OnRedTeamLose", activator, caller)
			fire_output("OnTeamLose", activator, caller)
			return TRUE
		if("blueteamlose")
			fire_output("OnBlueTeamLose", activator, caller)
			fire_output("OnTeamLose", activator, caller)
			return TRUE
		if("reddeath")
			fire_output("OnRedDeath", activator, caller)
			return TRUE
		if("bluedeath")
			fire_output("OnBlueDeath", activator, caller)
			return TRUE
		if("redjoin")
			fire_output("OnRedJoin", activator, caller)
			return TRUE
		if("bluejoin")
			fire_output("OnBlueJoin", activator, caller)
			return TRUE
	return FALSE

// Backwards compat alias
/obj/effect/map_entity/round_events
	name = "round_events"
	icon_state = "round_events"
	targetname = "round_events"

/obj/effect/map_entity/round_events/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("roundstart")
			fire_output("OnRoundStart", activator, caller)
			return TRUE
		if("roundend")
			fire_output("OnRoundEnd", activator, caller)
			return TRUE
	return FALSE

// Logic Branch - if/else logic
/obj/effect/map_entity/logic_branch
	name = "logic_branch"
	icon_state = "logic_branch"
	var/value = FALSE

/obj/effect/map_entity/logic_branch/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("test")
			if(value)
				fire_output("OnTrue", activator, caller)
			else
				fire_output("OnFalse", activator, caller)
			return TRUE
		if("settrue")
			value = TRUE
			return TRUE
		if("setfalse")
			value = FALSE
			return TRUE
		if("toggle")
			value = !value
			return TRUE
		if("setvalue")
			var/v = params?["value"]
			if(v)
				value = text2num(v) ? TRUE : FALSE
			return TRUE
	return FALSE

// Teleporter (updated with teleport_all)
/obj/effect/map_entity/teleporter
	name = "teleporter"
	icon_state = "trigger"
	is_brush = TRUE
	var/destination = ""
	var/one_way = FALSE
	var/auto_trigger = TRUE
	var/cooldown = 1 SECOND
	var/last_teleport_time = 0
	var/list/allowed_types = null
	var/teleport_sound = 'sound/effects/teleport.ogg'
	var/teleport_all = FALSE  // If TRUE, teleports everyone on map

/obj/effect/map_entity/teleporter/Crossed(atom/movable/AM)
	. = ..()
	if(!enabled || !auto_trigger)
		return
	if(!can_teleport(AM))
		return
	do_teleport(AM)

/obj/effect/map_entity/teleporter/proc/can_teleport(atom/movable/AM)
	if(cooldown > 0 && (world.time - last_teleport_time) < cooldown)
		return FALSE
	if(allowed_types && length(allowed_types))
		var/type_ok = FALSE
		for(var/T in allowed_types)
			if(istype(AM, T))
				type_ok = TRUE
				break
		if(!type_ok)
			return FALSE
	if(!ismob(AM) && !isobj(AM))
		return FALSE
	return TRUE

/obj/effect/map_entity/teleporter/proc/do_teleport(atom/movable/AM)
	if(!destination)
		return FALSE
	var/list/targets = find_io_targets(destination)
	if(!length(targets))
		return FALSE
	var/atom/dest = pick(targets)
	var/turf/dest_turf = get_turf(dest)
	if(!dest_turf)
		return FALSE
	if(get_turf(AM) == dest_turf)
		return FALSE
	last_teleport_time = world.time
	if(teleport_sound)
		playsound(src, teleport_sound, 50, TRUE)
		playsound(dest_turf, teleport_sound, 50, TRUE)
	if(ismob(AM))
		var/mob/M = AM
		if(M.buckled)
			M.buckled.unbuckle_mob(M)
	var/success = AM.forceMove(dest_turf)
	if(!success)
		return FALSE
	fire_output("OnTeleport", AM, src)
	if(istype(dest, /obj/effect/map_entity/teleporter))
		var/obj/effect/map_entity/teleporter/T = dest
		T.last_teleport_time = world.time
	return TRUE

/obj/effect/map_entity/teleporter/proc/teleport_everyone()
	if(!destination)
		return
	var/list/targets = find_io_targets(destination)
	if(!length(targets))
		return
	var/atom/dest = pick(targets)
	var/turf/dest_turf = get_turf(dest)
	if(!dest_turf)
		return
	for(var/mob/living/M in GLOB.player_list)
		if(M.stat == DEAD)
			continue
		if(M.buckled)
			M.buckled.unbuckle_mob(M)
		M.forceMove(dest_turf)
	if(teleport_sound)
		playsound(dest_turf, teleport_sound, 50, TRUE)
	fire_output("OnTeleport", null, src)

/obj/effect/map_entity/teleporter/receive_input(input_name, atom/activator, atom/caller, list/params)
	. = ..()
	if(.)
		return TRUE
	switch(lowertext(input_name))
		if("teleport")
			if(istype(activator, /atom/movable))
				var/atom/movable/AM = activator
				if(can_teleport(AM))
					do_teleport(AM)
			return TRUE
		if("teleportall")
			if(teleport_all)
				teleport_everyone()
			else
				for(var/atom/movable/AM in loc)
					if(can_teleport(AM))
						do_teleport(AM)
			return TRUE
	return FALSE

/obj/effect/map_entity/teleporter/oneway
	name = "teleporter_oneway"
	one_way = TRUE

/obj/effect/map_entity/teleporter/triggered
	name = "teleporter_triggered"
	auto_trigger = FALSE

// Info Target - just a position marker for other entities to reference
/obj/effect/map_entity/info_target
	name = "info_target"
	icon_state = "target_info"
	// No special behavior - exists for targetname lookup

