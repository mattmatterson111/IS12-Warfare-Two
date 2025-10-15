#define NONE 1
#define FORWARD 2
#define BACKWARD 3
#define BOTH 4

/obj/structure/track/
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "editor"
	var/obj/structure/track/next_track
	var/obj/structure/track/prev_track
	var/speed = 1
	var/canmove = TRUE
	var/angle = null

/obj/structure/track/Initialize()
	. = ..()
	next_track = locate(/obj/structure/track) in get_step(src, src.dir)
	next_track.prev_track = src
	//prev_track = locate(/obj/structure/track) in get_step(src, turn(src.dir, 180))
	canmove = BOTH
	if(prev_track && !next_track)
		canmove = BACKWARD
	else if(next_track && !prev_track)
		canmove = FORWARD
	else if(!next_track && !prev_track)
		canmove = NONE
	angle = dir2angle(dir)

/obj/structure/track/Crossed(O)
	. = ..()
	if(istype(O, /obj/structure/payload))
		var/obj/structure/payload/pl = O
		pl.current_track = src

/obj/structure/payload

	icon = 'code/modules/payload_gamemode/icons/payload.dmi'
	icon_state = "editor"

	var/obj/structure/track/current_track

	var/body_icon = "base"
	var/payload_icon = "red_payload"

	var/speed_per_player = 1
	var/warfare_faction = RED_TEAM

	/// Mob list to keep track of who's pushing
	var/list/pushers = list()
	/// Time since it last got pushed
	var/time_since_last_push = null
	/// Keeps track of how many times we've gone backwards
	var/tracks_passed = 0

	anchored = TRUE
	density = TRUE
	animate_movement = NO_STEPS

/obj/structure/payload/Initialize()
	. = ..()

	var/obj/track = locate(/obj/structure/track) in loc
	if(!track)
		return
	src.current_track = track

	var/current_dir = src.dir
	update_icon()

	var/angle = dir2angle(current_dir)

	if(track)
		angle = current_track.angle

	var/new_transform = src.transform.Turn(angle)
	src.transform = new_transform

	START_PROCESSING(SSfastprocess, src)

/obj/structure/payload/update_icon()
	. = ..()
	overlays.Cut()
	src.icon_state = src.body_icon
	overlays += mutable_appearance(icon, payload_icon)

/obj/structure/payload/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/payload/Process()

	/// Find all valid mobs nearby who can push
	var/list/nearby_pushers = list()
	for (var/mob/m in view(1, src))
		nearby_pushers |= m

	/// Remove anyone no longer in range
	for (var/mob/m in pushers)
		if (!(m in nearby_pushers))
			pushers -= m
			to_world("removed [m]")

	/// I won't bother to comment the rest of this shit
	for (var/mob/m in nearby_pushers)
		if (!(m in pushers))
			pushers |= m
			to_world("added [m]")

	if(length(pushers) && can_we_move(pushers, FORWARD))
		increment_to_track(src.speed_per_player * current_track.speed, current_track.next_track)
		src.time_since_last_push = world.time
		to_world("push")

	if(isnull(time_since_last_push)) return
	if(world.time - time_since_last_push > 10 SECONDS && !(tracks_passed >= 2) && can_we_move(pushers, BACKWARD))
		to_world("going back")
		increment_to_track(src.speed_per_player * current_track.speed, current_track.prev_track, BACKWARD)

/obj/structure/payload/proc/can_push(var/mob/m)
	if(isobserver(m)) return FALSE
	if(m.stat == DEAD || m.stat == UNCONSCIOUS) return FALSE
	if(m.warfare_faction == src.warfare_faction) return TRUE

/obj/structure/payload/proc/can_we_move(var/list/mobs, movedir)
	var/canmove = FALSE

	if(current_track.canmove == NONE) return canmove
	if((movedir == FORWARD && current_track.canmove == BOTH) || (movedir == FORWARD && current_track.canmove == FORWARD))
		canmove = TRUE
		return canmove
	if((movedir == BACKWARD && current_track.canmove == BOTH) || (movedir == BACKWARD && current_track.canmove == BACKWARD))
		canmove = TRUE
		return canmove
	if(movedir == BOTH)
		canmove = TRUE
		return canmove

	for(var/mob/m in mobs)
		if(!can_push(m)) continue
		if(m.warfare_faction != src.warfare_faction && movedir != BACKWARD)
			break
		else
			canmove = TRUE
			break

	return canmove

/obj/structure/payload/proc/return_to_middle(var/amount = 1)

/obj/structure/payload/proc/increment_to_track(var/amount = 1, var/obj/structure/track/track, movedir = FORWARD)
	if (!current_track || !track)
		return

	// Get pixel-space offsets toward next track
	var/pixel_w = ((track.x - src.x) * 32 + (track.pixel_x - src.pixel_x))
	var/pixel_z = ((track.y - src.y) * 32 + (track.pixel_y - src.pixel_y))

	// Move fractionally toward next track
	src.pixel_w += pixel_w * (amount / 32)
	src.pixel_z += pixel_z * (amount / 32)

	// Smooth rotation toward next track’s angle
	if (isnum(track.angle))
		var/angle_diff = track.angle - current_track.angle
		if(!angle_diff == 0)

			// Normalize to shortest rotation path
			if (angle_diff > 180)
				angle_diff -= 360
			else if (angle_diff < -180)
				angle_diff += 360

			src.transform = src.transform.Turn(angle_diff * (amount / 32))

	// --- Check for tile crossing ---
	if (abs(src.pixel_w) >= 32 || abs(src.pixel_z) >= 32)
		// Optional overshoot correction (keeps leftover pixel travel)

		src.forceMove(track.loc)
		src.pixel_w = 0
		src.pixel_z = 0
		current_track = track
		if(movedir == BACKWARD)
			tracks_passed++


/obj/structure/payload/proc/decrement_to_previous_track(var/amount = 1)