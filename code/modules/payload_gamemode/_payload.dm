


#define TRACK_NONE    0
#define TRACK_FORWARD 1
#define TRACK_BACKWARD 2
#define TRACK_BOTH    3


#define STATE_IDLE       1
#define STATE_FORWARD    2
#define STATE_BACKWARD   3
#define STATE_CONTESTED  4

/obj/structure/fluff_track
	name = "tracks"
	desc = "It tracks."
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "main"
	anchored = TRUE
	mouse_opacity = FALSE

/obj/structure/fluff_track/ex_act(severity)
	return



/obj/structure/track
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "editor"
	invisibility = 101
	anchored = TRUE
	mouse_opacity = FALSE

	var/obj/structure/track/next_track
	var/obj/structure/track/prev_track
	var/speed = 1
	var/angle = null

/obj/structure/track/ex_act(severity)
	return

/obj/structure/track/Initialize()
	. = ..()
	angle = dir2angle(dir)
	
	addtimer(CALLBACK(src, PROC_REF(link_tracks)), 1)

/obj/structure/track/proc/link_tracks()
	
	next_track = find_track_in_direction(dir)

	
	if(next_track)
		next_track.prev_track = src

/obj/structure/track/proc/find_track_in_direction(search_dir)
	
	var/obj/structure/track/found = null
	if(search_dir in GLOB.cardinal)
		found = locate(/obj/structure/track) in get_step(src, search_dir)
		if(found)
			return found

	
	switch(search_dir)
		if(NORTHWEST)
			found = locate(/obj/structure/track) in get_step(src, NORTH)
			if(!found) found = locate(/obj/structure/track) in get_step(src, NORTHWEST)
			if(!found) found = locate(/obj/structure/track) in get_step(src, WEST)
		if(NORTHEAST)
			found = locate(/obj/structure/track) in get_step(src, NORTH)
			if(!found) found = locate(/obj/structure/track) in get_step(src, NORTHEAST)
			if(!found) found = locate(/obj/structure/track) in get_step(src, EAST)
		if(SOUTHWEST)
			found = locate(/obj/structure/track) in get_step(src, SOUTH)
			if(!found) found = locate(/obj/structure/track) in get_step(src, SOUTHWEST)
			if(!found) found = locate(/obj/structure/track) in get_step(src, WEST)
		if(SOUTHEAST)
			found = locate(/obj/structure/track) in get_step(src, SOUTH)
			if(!found) found = locate(/obj/structure/track) in get_step(src, SOUTHEAST)
			if(!found) found = locate(/obj/structure/track) in get_step(src, EAST)

	return found


/obj/structure/track/proc/can_move_direction(movedir)
	switch(movedir)
		if(TRACK_FORWARD)
			return !!next_track
		if(TRACK_BACKWARD)
			return !!prev_track
		if(TRACK_BOTH)
			return next_track || prev_track
	return FALSE

/obj/structure/track/Crossed(O)
	. = ..()
	if(istype(O, /obj/structure/payload))
		var/obj/structure/payload/pl = O
		pl.current_track = src



GLOBAL_LIST_EMPTY(payloads)

/obj/structure/payload
	icon = 'code/modules/payload_gamemode/icons/payload.dmi'
	icon_state = "editor"
	plane = -110
	anchored = TRUE
	density = TRUE
	animate_movement = NO_STEPS

	var/obj/structure/track/current_track
	var/obj/structure/track/checkpoint  

	var/body_icon = "base"
	var/payload_icon = ""

	
	var/base_speed_mod = 1
	
	var/speed_mod = 1
	var/warfare_faction = RED_TEAM

	var/list/pushers = list()
	var/time_since_last_push = null

	var/state = STATE_IDLE
	var/current_angle = 0

	
	var/move_override = FALSE
	var/blocked_by_obstacle = FALSE

	
	
	var/push_start_time = null
	
	var/momentum_mult = 1
	
	var/max_momentum_mult = 3
	
	var/momentum_buildup_delay = 10 SECONDS
	
	var/momentum_decay_delay = 5 SECONDS
	
	var/last_stop_time = null

	
	
	var/turn_speed = 0.15

	
	
	var/list/aura_affected = list()
	
	var/wound_heal_chance = 5
	
	var/pain_reduction = 10

	
	var/datum/sound_token/active_sound
	var/last_sound_change = 0
	#define SOUND_CHANGE_COOLDOWN 5

/obj/structure/payload/ex_act(severity)
	return

/obj/structure/payload/Initialize()
	. = ..()

	current_track = locate(/obj/structure/track) in loc
	if(!current_track)
		return

	update_icon()

	current_angle = current_track ? dir2angle(current_track.dir) : dir2angle(dir)
	apply_rotation(current_angle)

	START_PROCESSING(SSfastprocess, src)
	play_sound_for_state(STATE_IDLE)
	GLOB.payloads += src

/obj/structure/payload/update_icon()
	. = ..()
	overlays.Cut()
	icon_state = body_icon
	overlays += mutable_appearance(icon, payload_icon)

/obj/structure/payload/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	stop_sound()
	GLOB.payloads -= src
	. = ..()

/obj/structure/payload/proc/stop_sound()
	if(active_sound)
		QDEL_NULL(active_sound)

/obj/structure/payload/proc/start_sound(sound_file, volume = 45, range = 4)
	stop_sound()
	active_sound = sound_player.PlayLoopingSound(src, "[type]_[sound_file]", sound_file, volume, range, 2, TRUE, TRUE)



/obj/structure/payload/Process()
	/*
	if(!SSwarfare.battle_time)
		return
	*/
	if(!current_track)
		return

	
	var/list/nearby_pushers = get_nearby_pushers()
	update_pusher_list(nearby_pushers)

	
	var/friendly_count = count_friendlies(nearby_pushers)

	
	update_momentum(nearby_pushers)
	speed_mod = base_speed_mod * momentum_mult

	var/speed = clamp(friendly_count, 0, 5) * speed_mod * current_track.speed

	
	apply_healing_aura()

	if(move_override)
		return

	
	var/has_friendly = count_friendlies(nearby_pushers) > 0

	if(!length(nearby_pushers) || !has_friendly)
		handle_no_pushers()
	else
		handle_pushers(nearby_pushers, speed)
		
		if(state == STATE_CONTESTED)
			check_regression()

/obj/structure/payload/proc/get_nearby_pushers()
	var/list/nearby = list()
	for(var/mob/living/M in GLOB.player_list)
		if(M.stat == DEAD || M.stat == UNCONSCIOUS || M.resting)
			continue
		if(get_dist(src, M) > 1)
			continue
		if(!isturf(M.loc))
			continue
		nearby |= M
	return nearby

/obj/structure/payload/proc/update_pusher_list(var/list/nearby_pushers)
	
	for(var/mob/living/M in pushers.Copy())
		if(!(M in nearby_pushers))
			pushers -= M
	
	for(var/mob/living/M in nearby_pushers)
		if(!(M in pushers))
			pushers |= M

/obj/structure/payload/proc/count_friendlies(var/list/mobs)
	var/count = 0
	for(var/mob/living/M in mobs)
		if(M.warfare_faction == warfare_faction && M.warfare_faction)
			count++
	return count

/obj/structure/payload/proc/has_enemies(var/list/mobs)
	for(var/mob/living/M in mobs)
		if(M.warfare_faction != warfare_faction || !M.warfare_faction)
			return TRUE
	return FALSE



/obj/structure/payload/proc/update_momentum(var/list/nearby_pushers)
	var/has_friendly = count_friendlies(nearby_pushers) > 0
	var/has_enemy = has_enemies(nearby_pushers)

	
	if(has_enemy)
		reset_momentum()
		return

	
	if(has_friendly && state == STATE_FORWARD)
		last_stop_time = null  

		
		if(!push_start_time)
			push_start_time = world.time

		
		var/push_duration = world.time - push_start_time
		if(push_duration >= momentum_buildup_delay)
			
			var/time_over_threshold = push_duration - momentum_buildup_delay
			momentum_mult = clamp(1 + (time_over_threshold / (10 SECONDS)) * 0.5, 1, max_momentum_mult)
		return

	
	if(!has_friendly || state != STATE_FORWARD)
		
		if(!last_stop_time)
			last_stop_time = world.time

		
		if(world.time - last_stop_time >= momentum_decay_delay)
			reset_momentum()

/obj/structure/payload/proc/reset_momentum()
	push_start_time = null
	last_stop_time = null
	momentum_mult = 1


/obj/structure/payload/proc/modify_base_speed(modifier, operation = "multiply")
	switch(operation)
		if("multiply")
			base_speed_mod *= modifier
		if("add")
			base_speed_mod += modifier
		if("set")
			base_speed_mod = modifier
		if("reset")
			base_speed_mod = initial(base_speed_mod)



/obj/structure/payload/proc/get_aura_color()
	switch(warfare_faction)
		if(RED_TEAM)
			return rgb(255, 200, 200)
		if(BLUE_TEAM)
			return rgb(200, 200, 255)
		else
			return rgb(255, 255, 255)

/obj/structure/payload/proc/apply_healing_aura()
	var/aura_color = get_aura_color()

	
	var/list/current_in_range = list()
	for(var/mob/living/carbon/human/H in range(1, src))
		if(H.stat == DEAD)
			continue
		if(H.warfare_faction != warfare_faction)
			continue
		if(H.lying)
			continue
		current_in_range |= H

	
	for(var/mob/living/carbon/human/H in aura_affected.Copy())
		if(!(H in current_in_range))
			remove_aura_effect(H)
			aura_affected -= H
			H.pushing_cart = FALSE

	
	for(var/mob/living/carbon/human/H in current_in_range)
		if(!(H in aura_affected))
			apply_aura_effect(H, aura_color)
			aura_affected |= H
			H.pushing_cart = TRUE
		else
			
			apply_aura_healing(H)

/obj/structure/payload/proc/apply_aura_effect(mob/living/carbon/human/H, aura_color)
	
	if(!H.payload_original_color)
		H.payload_original_color = H.color
	H.color = aura_color
	apply_aura_healing(H)

/obj/structure/payload/proc/apply_aura_healing(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return

	
	H.adjustBruteLoss(-0.5)
	H.adjustFireLoss(-0.5)

	
	if(prob(wound_heal_chance))
		for(var/obj/item/organ/external/E in H.organs)
			if(length(E.wounds))
				var/datum/wound/W = pick(E.wounds)
				if(W)
					E.wounds -= W
					qdel(W)
				break

/obj/structure/payload/proc/remove_aura_effect(mob/living/carbon/human/H)
	
	if(H.payload_original_color)
		H.color = H.payload_original_color
		H.payload_original_color = null
	else
		H.color = null



/obj/structure/payload/proc/handle_no_pushers()
	
	if(time_since_last_push && (world.time - time_since_last_push > 10 SECONDS))
		
		if(!current_track.prev_track || current_track == checkpoint)
			set_state(STATE_IDLE)
			return

		
		set_state(STATE_BACKWARD)
		move_toward_track(current_track.prev_track, base_speed_mod * current_track.speed, TRACK_BACKWARD)
	else
		
		if(state != STATE_BACKWARD)  
			set_state(STATE_IDLE)



/obj/structure/payload/proc/check_regression()
	
	if(!time_since_last_push || (world.time - time_since_last_push <= 10 SECONDS))
		return

	
	if(!current_track.prev_track || current_track == checkpoint)
		return

	
	move_toward_track(current_track.prev_track, base_speed_mod * current_track.speed, TRACK_BACKWARD)

/obj/structure/payload/proc/handle_pushers(var/list/nearby_pushers, speed)
	var/has_friendly = count_friendlies(nearby_pushers) > 0
	var/has_enemy = has_enemies(nearby_pushers)

	
	if(has_friendly && !has_enemy)
		
		if(!current_track.next_track)
			set_state(STATE_IDLE)
			return

		set_state(STATE_FORWARD)
		move_toward_track(current_track.next_track, speed, TRACK_FORWARD)
		time_since_last_push = world.time
		return

	
	
	
	set_state(STATE_CONTESTED)
	

/obj/structure/payload/proc/set_state(new_state)
	if(state == new_state)
		return

	var/old_state = state
	state = new_state

	
	if(new_state == STATE_CONTESTED && old_state != STATE_CONTESTED)
		playsound(loc, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)

	
	if(new_state == STATE_IDLE && (old_state == STATE_FORWARD || old_state == STATE_BACKWARD))
		if(!current_track.next_track || !current_track.prev_track || current_track == checkpoint)
			playsound(loc, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)

	play_sound_for_state(new_state)

/obj/structure/payload/proc/play_sound_for_state(target_state)
	if(world.time - last_sound_change < SOUND_CHANGE_COOLDOWN)
		return
	last_sound_change = world.time

	
	if(blocked_by_obstacle && target_state == STATE_FORWARD)
		target_state = STATE_IDLE

	switch(target_state)
		if(STATE_IDLE, STATE_CONTESTED)
			start_sound('sound/effects/payload/bomb_tick_loop.ogg', 5)
		if(STATE_FORWARD)
			start_sound('sound/effects/payload/cart_move_loop.ogg', 45)
		if(STATE_BACKWARD)
			start_sound('sound/effects/payload/cart_regress.ogg', 45)



/obj/structure/payload/proc/move_toward_track(var/obj/structure/track/target, amount, movedir)
	if(!current_track || !target)
		return

	
	if(!current_track.can_move_direction(movedir))
		return

	
	
	
	if(movedir == TRACK_FORWARD)
		for(var/obj/O in target.loc)
			
			if(istype(O, /obj/structure/barbwire) || istype(O, /obj/structure/defensive_barrier))
				qdel(O)
				continue

			if(O.density && O.anchored && !ismob(O))
				
				
				if(istype(O, /obj/structure/track)) continue
				
				if(!blocked_by_obstacle)
					blocked_by_obstacle = TRUE
					playsound(src, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)
					play_sound_for_state(STATE_IDLE)
				return

	if(blocked_by_obstacle)
		blocked_by_obstacle = FALSE
		play_sound_for_state(state)

	
	var/world_diff_x = ((target.x - x) * 32) + (target.pixel_x - pixel_x)
	var/world_diff_y = ((target.y - y) * 32) + (target.pixel_y - pixel_y)

	
	var/distance = sqrt(world_diff_x ** 2 + world_diff_y ** 2)
	if(distance == 0)
		return

	var/dir_x = world_diff_x / distance
	var/dir_y = world_diff_y / distance

	
	pixel_x += dir_x * amount
	pixel_y += dir_y * amount

	
	interpolate_rotation(target)

	
	if(abs(pixel_x) >= 32 || abs(pixel_y) >= 32)
		snap_to_track(target)

/obj/structure/payload/proc/interpolate_rotation(var/obj/structure/track/target)
	if(!isnum(target.angle) || !isnum(current_track.angle))
		return

	var/angle_diff = target.angle - current_angle

	
	while(angle_diff > 180)
		angle_diff -= 360
	while(angle_diff < -180)
		angle_diff += 360

	
	current_angle += angle_diff * turn_speed
	apply_rotation(current_angle)

/obj/structure/payload/proc/apply_rotation(angle)
	var/matrix/M = matrix()
	M.Turn(angle)
	transform = M

/obj/structure/payload/proc/snap_to_track(var/obj/structure/track/target)
	forceMove(target.loc)

	
	for(var/obj/effect/landmark/payload_marker/effect in target.loc)
		effect.on_run(src)

	
	pixel_x = 0
	pixel_y = 0
	current_track = target
	current_angle = target.angle



/obj/structure/payload/blue
	body_icon = "blue"
	payload_icon = "blue_payload"
	warfare_faction = BLUE_TEAM

/obj/structure/payload/red
	body_icon = "red"
	payload_icon = "red_payload"



#undef TRACK_NONE
#undef TRACK_FORWARD
#undef TRACK_BACKWARD
#undef TRACK_BOTH

#undef STATE_IDLE
#undef STATE_FORWARD
#undef STATE_BACKWARD
#undef STATE_CONTESTED

#undef SOUND_CHANGE_COOLDOWN
