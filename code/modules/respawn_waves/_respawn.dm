/// Related to waves
/datum/team/var/respawn_id

/obj/effect/landmark/start/redcoats
	name = RED_TEAM
	icon = 'icons/effects/teleport.dmi'
	icon_state = "redcoats_spawn"

/obj/effect/landmark/start/bluecoats
	name = BLUE_TEAM
	icon = 'icons/effects/teleport.dmi'
	icon_state = "bluecoats_spawn"

/obj/effect/darkout_teleporter/redcoats
	icon = 'icons/effects/teleport.dmi'
	icon_state = "redcoats"
	id = RED_TEAM

/obj/effect/darkout_teleporter/bluecoats
	icon = 'icons/effects/teleport.dmi'
	icon_state = "bluecoats"
	id = BLUE_TEAM

/obj/structure/vehicle/train
	icon = 'icons/obj/respawn_trains/train.dmi'
	icon_state = "editor_engine"
	plane = ABOVE_HUMAN_PLANE
	layer = ABOVE_HUMAN_LAYER
	var/id = ""
	var/carriage_amount = 1
	var/engine_state = "train_locomotive-new"
	var/filler_states = "train_passenger-new"
	var/ending_states = "train_passenger_end-new"
	var/special_carriage = "train_entry-new"
	appearance_flags = 0 // Don't disappear out of view please.
	var/list/landmarks = list()
	var/open
	var/list/carriage_cache = list()
	static_pixel_y = 15

/obj/structure/vehicle/train/proc/generate_carriages()
	overlays.Cut()
	if(dir != SOUTH)
		static_pixel_x = -static_pixel_x
	icon_state = ""

	to_world("carriage amount: [carriage_amount] with filler states: [filler_states], ending states: [ending_states], and special carriage: [special_carriage]")

	if(!carriage_amount)
		carriage_amount = 1
	if(!isnum(carriage_amount))
		carriage_amount = text2num(carriage_amount)

	var/image/I = image(icon, src, engine_state)
	I.pixel_x = static_pixel_x
	overlays += I

	var/pixel_offset_x = (dir == SOUTH) ? -144 : 144

	for(var/i in 0 to carriage_amount)
		var/state

		if(i == 0 && special_carriage)
			state = get_special_carriage_state()
		else if(i == carriage_amount && ending_states)
			state = get_ending_carriage_state()
		else
			state = get_or_cache_filler_state(i)

		to_world("Carriage: [i] with state: [state]")

		I = image(icon, src, state)
		I.pixel_x = pixel_offset_x + static_pixel_x
		overlays += I

		pixel_offset_x += (dir == SOUTH) ? -144 : 144

/obj/structure/vehicle/train/proc/get_or_cache_filler_state(index)
	if(carriage_cache.len >= index + 1)
		return carriage_cache[index + 1] // BYOND is 1-indexed
	else
		var/state = get_filler_carriage_state()
		carriage_cache += state
		return state

/obj/structure/vehicle/train/proc/clear_carriage_cache()
	carriage_cache.Cut()


/obj/structure/vehicle/train/proc/get_special_carriage_state()
	return special_carriage

/obj/structure/vehicle/train/proc/get_filler_carriage_state()
	return islist(filler_states) ? pick(filler_states) : filler_states

/obj/structure/vehicle/train/proc/get_ending_carriage_state()
	return islist(ending_states) ? pick(ending_states) : ending_states


/obj/structure/vehicle/train/long_passenger/get_special_carriage_state()
	return open ? "[special_carriage]-o" : special_carriage

/obj/structure/vehicle/train/Initialize()
	. = ..()
	if(dir != SOUTH)
		dir = NORTH
	generate_carriages()
	for(var/obj/effect/landmark/train_marker/landmark in landmarks_list)
		to_world("Got landmark")
		if(landmark.id == id)
			to_world("ID matches")
			if(istype(landmark, /obj/effect/landmark/train_marker/entry) && !landmarks["entry"])
				landmarks["entry"] = landmark
				continue
			else if(istype(landmark, /obj/effect/landmark/train_marker/idle) && !landmarks["idle"])
				landmarks["idle"] = landmark
				continue
			else if(istype(landmark, /obj/effect/landmark/train_marker/exit) && !landmarks["exit"])
				landmarks["exit"] = landmark
				continue
		if(!length(landmarks_list) == 3)
			message_admins("Train [id] has not enough landmarks, expected 3, got [length(landmarks)]")
	to_world("Train [id] has landmarks: [length(landmarks)]")

/obj/structure/vehicle/train/long_passenger
	carriage_amount = 4
	static_pixel_x = 110

/obj/structure/vehicle/train/long_passenger/Initialize()
	carriage_amount = rand(1, initial(carriage_amount))
	. = ..()
	if(id && length(landmarks) == 3)
		if(!SSrespawn.trains[id])
			SSrespawn.trains[id] = src
			message_admins("Setting train [id].")
		else
			message_admins("Train with ID [id] already exists, overwriting.")
			SSrespawn.trains[id] = src

/obj/structure/vehicle/train/random
	carriage_amount = 5
	special_carriage = null
	filler_states = list("train_artillery-new", "train_tank-new", "train_full-new", "train_AA-new", "train_container_metal-new", "train_container_viridian-new", "train_container_red-new", "train_container_orange-new", "train_container_viridian-new", "train_tarp_empty-new", "train_container_empty-new", "train_empty-new")
	ending_states = null
	static_pixel_x = 144

/obj/structure/vehicle/train/random/cargo
	special_carriage = "train_full-new"
	static_pixel_x = 120

/obj/structure/vehicle/train/random/cargo/attack_hand(mob/user)
	. = ..()
	var/free = 0
	if(!user.get_inactive_hand() && !user.get_active_hand())
		free = TRUE
	if(!free)
		return FALSE
	var/obj/item/I = new/obj/item/forcewield(get_turf(user))
	user.put_in_active_hand(I)
	return TRUE

/area/train
	requires_power = FALSE

/area/train/Entered(A)
	. = ..()
	if(ismob(A))
		var/mob/M = A
		if(!M.client) return
		sound_to(M, sound('sound/effects/train_loop_inside.ogg', channel = 76, volume = 85, repeat = 1))

/area/train/Exited(atom/movable/exitee, atom/new_loc)
	. = ..()
	if(ismob(exitee))
		var/mob/M = exitee
		if(!M.client) return
		sound_to(M, sound(null, channel = 76))

/area/train/red
	icon_state = "redcoats"
/area/train/blue
	icon_state = "bluecoats"

/obj/structure/vehicle/train/proc/arrive(extra_distance)
	if(!length(landmarks) == 3)
		message_admins("Train [id] does not have enough landmarks.")
		return
	var/obj/anchor = landmarks["idle"]
	forceMove(anchor.loc)
	var/gettox = 0
	var/gettoy = static_pixel_y
	var/getfromx = getpixel_x(landmarks["entry"]) + extra_distance
	var/getfromy = getpixel_y(landmarks["entry"]) + static_pixel_y
	to_world("Arriving at [anchor] with from: [getfromx], [getfromy] and to: [gettox], [gettoy]")
	pixel_x = getfromx
	pixel_y = getfromy
	animate(src, pixel_x = gettox, pixel_y = gettoy, time = 8 SECONDS, easing = SINE_EASING)

/obj/structure/vehicle/train/proc/pass(extra_distance, timetopass = 8 SECONDS)
	if(!length(landmarks) == 3)
		message_admins("Train [id] does not have enough landmarks.")
		return
	var/obj/anchor = landmarks["idle"]
	forceMove(anchor.loc)
	var/getfromx = getpixel_x(landmarks["entry"]) + extra_distance
	var/getfromy = getpixel_y(landmarks["entry"]) + static_pixel_y
	var/gettox = getpixel_x(landmarks["exit"]) + extra_distance
	var/gettoy = getpixel_y(landmarks["exit"]) + static_pixel_y
	to_world("Arriving at [anchor] with from: [getfromx], [getfromy] and to: [gettox], [gettoy]")
	pixel_x = getfromx
	pixel_y = getfromy
	animate(src, pixel_x = gettox, pixel_y = gettoy, time = timetopass, easing = SINE_EASING)

/obj/structure/vehicle/train/proc/leave(extra_distance)
	if(!length(landmarks) == 3)
		message_admins("Train [id] does not have enough landmarks.")
		return
	var/obj/anchor = landmarks["idle"]
	forceMove(anchor.loc) // make sure
	var/getfromx = 0
	var/getfromy = static_pixel_y
	var/gettox = getpixel_x(landmarks["exit"]) + extra_distance
	var/gettoy = getpixel_y(landmarks["exit"]) + static_pixel_y
	pixel_x = getfromx
	pixel_y = getfromy
	animate(src, pixel_x = gettox, pixel_y = gettoy, time = 8 SECONDS, easing = SINE_EASING)
	spawn(8 SECONDS)
		forceMove(initial(loc))
		carriage_amount = rand(0, initial(carriage_amount))

SUBSYSTEM_DEF(respawn)
	name = "R.E.S.P.A.W.N & Train Control"
	priority = -40
	flags = SS_KEEP_TIMING | SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 10 SECONDS

	var/datum/team/blue
	var/datum/team/red
	var/respawn_cycle = 0
	var/next_respawn
	var/last_respawn = 0
	var/time_between_respawns = 60 SECONDS // in seconds

	var/area/red_train
	var/area/blue_train

	var/list/trains = list() // Train_ID = trainobj
	var/respawning = FALSE

	var/last_cargo_time = 0
	var/time_between_cargo = 250 // or any value less than `time_between_respawns`


/datum/controller/subsystem/respawn/Initialize()
	blue = SSwarfare.blue
	red = SSwarfare.red

	if (!blue.respawn_id)
		blue.respawn_id = BLUE_TEAM
	if (!red.respawn_id)
		red.respawn_id = RED_TEAM

	red_train = locate(/area/train/red) in world
	blue_train = locate(/area/train/blue) in world

/datum/controller/subsystem/respawn/proc/handle_team_respawn(var/area/train_area, var/landmark_type, var/team_name)
	var/list/valid_tp = list()
	for (var/obj/effect/landmark/train_marker/teleport/tp in landmarks_list)
		if (!istype(tp, landmark_type)) continue
		valid_tp += tp

	if (!length(valid_tp))
		message_admins("No valid [team_name] team teleport markers found for respawn, aborting.")
		return FALSE

	for (var/mob/M in train_area)
		var/obj/effect/landmark/train_marker/teleport/spot = pick(valid_tp)
		M.forceMove(spot.loc)
	return TRUE

/datum/controller/subsystem/respawn/proc/open_train(var/obj/structure/vehicle/train/T)
	if (!T) return
	T.open = TRUE
	T.generate_carriages()

/datum/controller/subsystem/respawn/proc/close_train(var/obj/structure/vehicle/train/T)
	if (!T) return
	T.open = FALSE
	T.generate_carriages()

/datum/controller/subsystem/respawn/fire(resumed)
	if (!SSwarfare.battle_time)
		return

	// Rarely try to spawn a passing train mid-cycle
	if (respawning)
		if (!prob(5)) return

		var/obj/structure/vehicle/train/T = pick(trains)
		if (!istype(T, /obj/structure/vehicle/train)) return
		message_admins("Trying to spawn a passing train: [T.id]")
		T.pass(500, 5 SECONDS)
		return
	/*
	if (!respawning && world.time - last_cargo_time >= time_between_cargo)
		to_world("Attempting to send cargo train...")
		send_cargo_train()
		return
	*/
	// Start a new respawn cycle
	if (world.time >= next_respawn || !next_respawn)
		if (!respawn_cycle)
			message_admins("Respawn cycle system is now online.")

		respawning = TRUE
		to_world("Respawn cycle #[respawn_cycle ? respawn_cycle : 0] started, next: [next_respawn ? next_respawn : "To be determined"], last: [last_respawn ? last_respawn : "Just now"]")
		var/obj/structure/vehicle/train/long_passenger/TR = trains[RED_TEAM]
		var/obj/structure/vehicle/train/long_passenger/TB = trains[BLUE_TEAM]

		TR?.generate_carriages()
		TB?.generate_carriages()

		TR?.arrive(-1000)
		TB?.arrive(-1000)

		sleep(3 SECONDS)

		playsound(TR, 'sound/effects/train_stop.ogg', 75, 0)
		playsound(TR, 'sound/effects/train_brake.ogg', 75, 0)
		playsound(TB, 'sound/effects/train_stop.ogg', 75, 0)
		playsound(TB, 'sound/effects/train_brake.ogg', 75, 0)

		sleep(5 SECONDS)

		open_train(TR)
		open_train(TB)

		sleep(1 SECOND)

		handle_team_respawn(red_train, /obj/effect/landmark/train_marker/teleport/red, "red")
		handle_team_respawn(blue_train, /obj/effect/landmark/train_marker/teleport/blue, "blue")

		sleep(8 SECONDS)

		close_train(TR)
		close_train(TB)

		playsound(TR, 'sound/effects/train_start.ogg', 75, 0)
		playsound(TB, 'sound/effects/train_start.ogg', 75, 0)

		sleep(1 SECOND)

		TR?.leave(1000)
		TB?.leave(1000)

		message_admins("Respawn cycle #[respawn_cycle] completed. Next: [next_respawn], Last: [last_respawn]")

		respawn_cycle++
		next_respawn = world.time + time_between_respawns
		last_respawn = world.time
		respawning = FALSE



/datum/controller/subsystem/respawn/proc/send_cargo_train()
	return
/*
	if (!cargo_train) return
	if (world.time - last_cargo_time < time_between_cargo) return

	to_world("Cargo train arriving...")

	cargo_train.generate_carriages()
	cargo_train.arrive(-1000)

	sleep(2 SECONDS)

	playsound(cargo_train, 'sound/effects/train_stop.ogg', 75, 0)
	playsound(cargo_train, 'sound/effects/train_brake.ogg', 75, 0)

	sleep(5 SECONDS)

	playsound(cargo_train, 'sound/effects/train_start.ogg', 75, 0)

	sleep(1 SECOND)

	cargo_train.leave(1000)

	last_cargo_time = world.time
*/