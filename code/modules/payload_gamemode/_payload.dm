/* -------------------------------------------------------------------------- */
/*                           THIS FILE BARELY WORKS                           */
/* -------------------------------------------------------------------------- */
/* ---------- THE CODE IS THROWN TOGETHER FOR AN IN-THE-MOMENT FIX ---------- */
/* ------------------ POKE ME TO FIX THE CART'S SHITTY CODE ----------------- */



#define NONE 1
#define FORWRD 2
#define BCKWRD 3
#define BOTH 4

#define CONTESTED 1
#define MOVING_FORWARD 2
#define MOVING_BACKWARD 3
#define IDLE_STATE 4

/obj/structure/fluff_track/
	name = "tracks"
	desc = "It tracks."
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "main"
	anchored = TRUE
	mouse_opacity = FALSE

/obj/structure/track/
	icon = 'code/modules/payload_gamemode/icons/tracks.dmi'
	icon_state = "editor"
	var/obj/structure/track/next_track
	var/obj/structure/track/prev_track
	var/speed = 1
	var/canmove = TRUE
	var/angle = null
	invisibility = 101
	anchored = TRUE
	mouse_opacity = FALSE
	//var/track_icon = "v1"

/obj/structure/track/Initialize()
	. = ..()
	//icon_state = track_icon
	switch(dir)
		if(EAST)
			next_track = locate(/obj/structure/track) in get_step(src, EAST)
		if(WEST)
			next_track = locate(/obj/structure/track) in get_step(src, WEST)
		if(NORTH)
			next_track = locate(/obj/structure/track) in get_step(src, NORTH)
		if(SOUTH)
			next_track = locate(/obj/structure/track) in get_step(src, SOUTH)
		if(NORTHWEST)
			next_track = locate(/obj/structure/track) in get_step(src, NORTH)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, NORTHWEST)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, WEST)

		if(NORTHEAST)
			next_track = locate(/obj/structure/track) in get_step(src, NORTH)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, NORTHEAST)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, EAST)

		if(SOUTHWEST)
			next_track = locate(/obj/structure/track) in get_step(src, SOUTH)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, SOUTHWEST)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, WEST)

		if(SOUTHEAST)
			next_track = locate(/obj/structure/track) in get_step(src, SOUTH)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, SOUTHEAST)
			if(!next_track)
				next_track = locate(/obj/structure/track) in get_step(src, EAST)
	//next_track.prev_track = src
	//prev_track = locate(/obj/structure/track) in get_step(src, turn(src.dir, 180))
	canmove = NONE
	if(next_track)
		next_track.prev_track = src

	if(next_track && !prev_track)
		canmove = FORWRD

	if(!next_track && prev_track)
		canmove = BCKWRD

	if(!next_track && !prev_track)
		canmove = NONE

	if(next_track && prev_track)
		canmove = BOTH

	angle = dir2angle(dir)

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

	var/obj/structure/track/current_track

	var/body_icon = "base"
	var/payload_icon = ""

	var/speed_mod = 1
	var/warfare_faction = RED_TEAM

	/// Mob list to keep track of who's pushing
	var/list/pushers = list()
	/// Time since it last got pushed
	var/time_since_last_push = null
	var/obj/checkpoint = null // checkpoint

	var/state = IDLE_STATE

	var/move_override = FALSE

	var/current_angle = 0

	anchored = TRUE
	density = TRUE
	animate_movement = NO_STEPS

/obj/structure/payload/Initialize()
	. = ..()

	var/obj/track = locate(/obj/structure/track) in loc
	if(!track)
		return
	src.current_track = track

	update_icon()

	src.current_angle = dir2angle(src.dir)

	if(track)
		src.current_angle = dir2angle(track.dir)

	var/new_transform = src.transform.Turn(current_angle)
	src.transform = new_transform

	setup_sound()

	START_PROCESSING(SSfastprocess, src)

	sound_emitter.play("bomb_tick_loop")

	GLOB.payloads += src

/obj/structure/payload/update_icon()
	. = ..()
	overlays.Cut()
	src.icon_state = src.body_icon
	overlays += mutable_appearance(icon, payload_icon)

/obj/structure/payload/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/payload/setup_sound()
	sound_emitter = new(src, is_static = TRUE, audio_range = 4)

	var/sound/bomb_tick_loop = sound('sound/effects/payload/bomb_tick_loop.ogg')
	bomb_tick_loop.repeat = TRUE
	bomb_tick_loop.volume = 5
	sound_emitter.add(bomb_tick_loop, "bomb_tick_loop")

	var/sound/cart_move_loop = sound('sound/effects/payload/cart_move_loop.ogg')
	cart_move_loop.repeat = TRUE
	cart_move_loop.volume = 45
	sound_emitter.add(cart_move_loop, "cart_move_loop")

	var/sound/cart_regress = sound('sound/effects/payload/cart_regress.ogg')
	cart_regress.repeat = TRUE
	cart_regress.volume = 45
	sound_emitter.add(cart_regress, "cart_regress_loop")

/obj/structure/payload/Process()
	if(!SSwarfare.battle_time) return
	if(move_override) return

	var/speed = 1

	var/list/nearby_pushers = list()
	for (var/mob/living/m in GLOB.player_list)
		if(m.stat == DEAD || m.stat == UNCONSCIOUS || m.resting) continue // this is checked like 5 times over i need to make it only here later idgaf rn
		if(get_dist(src, m) > 1) continue
		if(!isturf(m.loc)) continue
		nearby_pushers |= m

	speed = clamp(friendly_amount(nearby_pushers), 0, 5)
	speed *= speed_mod

	for (var/mob/living/m in pushers.Copy())
		if (!(m in nearby_pushers))
			pushers -= m

	for (var/mob/living/m in nearby_pushers)
		if (!(m in pushers))
			pushers |= m

	if(!length(nearby_pushers))
		if(state != IDLE_STATE && state != MOVING_BACKWARD)
			sound_emitter.stop()
			sound_emitter.play("bomb_tick_loop")
			state = IDLE_STATE

	if(world.time - time_since_last_push > 10 SECONDS && time_since_last_push)
		if(!current_track.prev_track || current_track == checkpoint)
			if(state == IDLE_STATE) return
			playsound(loc, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)
			sound_emitter.stop()
			sound_emitter.play("bomb_tick_loop")
			state = IDLE_STATE
			return
		if(state != MOVING_BACKWARD && state != 66) // i hate htis fix it later
			sound_emitter.stop()
			sound_emitter.play("cart_regress_loop")
			state = MOVING_BACKWARD
		increment_to_track((1 * speed_mod) * current_track.speed, current_track.prev_track, BCKWRD)

	var/should_we_stop = check_contested(nearby_pushers)

	if(should_we_stop == CONTESTED && state != CONTESTED)
		playsound(loc, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)
		sound_emitter.stop()
		sound_emitter.play("bomb_tick_loop")
		state = CONTESTED
		return

	if(state == CONTESTED || should_we_stop == 66)
		state = should_we_stop
		return

	if(should_we_stop == 66) return

	if(length(pushers)) // GOD FUCKING DAMN IT
		if(!current_track.next_track)
			if(state == IDLE_STATE) return
			playsound(loc, "sound/effects/payload/cart_contested_[rand(1,3)].ogg", 75, FALSE)
			sound_emitter.stop()
			sound_emitter.play("bomb_tick_loop")
			state = IDLE_STATE
			return
		if(state != CONTESTED)
			increment_to_track(speed * current_track.speed, current_track.next_track)
			src.time_since_last_push = world.time
			if(state != MOVING_FORWARD)
				sound_emitter.stop()
				sound_emitter.play("cart_move_loop")
				state = MOVING_FORWARD
	if(isnull(time_since_last_push)) return

/obj/structure/payload/proc/friendly_amount(var/list/mobs)
	var/friendlies = 0
	for(var/mob/living/m in mobs)
		if(src.warfare_faction != m.warfare_faction || !m.warfare_faction)
			continue
		friendlies++
	return friendlies

/obj/structure/payload/proc/check_contested(var/list/mobs)
	if(state == MOVING_BACKWARD || state == IDLE_STATE) return FALSE
	var/friendly = FALSE
	var/enemy = FALSE
	for(var/mob/living/m in mobs)
		if(src.warfare_faction != m.warfare_faction || !m.warfare_faction)
			enemy = TRUE
		else
			friendly = TRUE
		if(friendly && enemy) break
	if(friendly && enemy)
		return CONTESTED
	if(enemy && !friendly)
		return 66 // magic number fuCK YOU
	return

/obj/structure/payload/proc/can_we_move(var/list/mobs, movedir)
	var/canmove = FALSE
	if(current_track.canmove == NONE) return canmove
	if((movedir == FORWRD && current_track.canmove == BOTH) || (movedir == FORWRD && current_track.canmove == FORWRD))
		canmove = TRUE
		return canmove
	if((movedir == BCKWRD && current_track.canmove == BOTH) || (movedir == BCKWRD && current_track.canmove == BCKWRD))
		canmove = TRUE
		return canmove
	if(movedir == BOTH)
		canmove = TRUE
		return canmove

	return canmove

/obj/structure/payload/proc/increment_to_track(var/amount = 1, var/obj/structure/track/track, movedir = FORWRD)
	if (!current_track || !track)
		return

	var/pixel_w_total = ((track.x - src.x) + (track.pixel_x - src.pixel_x))
	var/pixel_z_total = ((track.y - src.y) + (track.pixel_y - src.pixel_y))

	pixel_w += pixel_w_total * amount
	pixel_z += pixel_z_total * amount

	if (isnum(track.angle) && isnum(current_track.angle))
		var/target_angle = track.angle
		var/current_angle = current_track.angle
		var/angle_diff = target_angle - current_angle

		var/fuck = current_angle + angle_diff

		// --- Apply the rotation ---
		var/matrix/M = matrix()
		M.Turn(fuck)
		src.transform = M

	if (abs(src.pixel_w) >= 32 || abs(src.pixel_z) >= 32)

		src.forceMove(track.loc)

		var/obj/effect/payload/C = locate(/obj/effect/payload) in track.loc // only one do not stack them i dont want you to
		if (C)
			C.on_run(src)

		src.pixel_w = 0
		src.pixel_z = 0
		current_track = track

/obj/structure/payload/blue
	body_icon = "blue"
	payload_icon = "blue_payload"
	warfare_faction = BLUE_TEAM

/obj/structure/payload/red
	body_icon = "red"
	payload_icon = "red_payload"

#undef CONTESTED
#undef MOVING_FORWARD
#undef MOVING_BACKWARD
#undef IDLE_STATE

#undef NONE
#undef FORWRD
#undef BCKWRD
#undef BOTH
