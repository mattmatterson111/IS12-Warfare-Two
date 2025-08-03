/obj/effect/darkout_teleporter
	name = ""
	desc = ""
	icon = 'icons/hammer/source.dmi'
	icon_state = "tools/black"
	allowtooltip = FALSE
	density = TRUE
	invisibility = 101
	var/delay = 20
	var/id
	var/enabled = TRUE
	var/list/valid = list() // List of other valid teleporters with the same ID
	var/entrance
	var/twoway

/obj/effect/darkout_teleporter/CanPass(atom/movable/mover, turf/target, height, air_group)
	return TRUE

GLOBAL_LIST_EMPTY(teleports)

/obj/effect/darkout_teleporter/Initialize()
	. = ..()
	if (!id)
		return
	if (!GLOB.teleports[id])
		GLOB.teleports[id] = list()
	GLOB.teleports[id] += src
	pop_valid_list()

/obj/effect/darkout_teleporter/proc/pop_valid_list()
	if(!islist(valid))
		valid = list()
	if(length(valid))
		valid.Cut()
	var/list/group = GLOB.teleports[id]
	if (!group)
		return

	for (var/obj/effect/darkout_teleporter/t in group)
		if (t == src)
			continue

		// Skip if same type (entrance-to-entrance or exit-to-exit)
		if (t.entrance == src.entrance)
			continue

		// Skip if target is not two-way and you're trying to go back
		if (!t.twoway && src.entrance == t.entrance)
			continue

		valid += t

/obj/effect/darkout_teleporter/Crossed(mob/living/user)
	if (!enabled || user.doing_something)
		return

	if (!length(valid))
		pop_valid_list()
		if(!length(valid))
			return // No valid destinations

	user.doing_something = TRUE

	if (do_after(user, delay, stay_still = TRUE))
		var/turf/exit = get_turf(pick(valid))
		if (!exit)
			user.doing_something = FALSE
			return

		if (user.pulling)
			user.pulling.forceMove(exit)

		user.forceMove(exit)
		playsound(src, 'sound/effects/ladder.ogg', 75, 1)
		playsound(exit, 'sound/effects/ladder.ogg', 75, 1)
	user.doing_something = FALSE

/proc/update_teleports(id)
	for (var/obj/effect/darkout_teleporter/t in GLOB.teleports[id])
		t.pop_valid_list()

/obj/effect/darkout_teleporter/proc/change_id(var/new_id)
	// Remove from old group
	if (GLOB.teleports[id])
		GLOB.teleports[id] -= src

	// Force old group to recalculate their valid lists

	// Update ID
	id = new_id

	// Add to new group
	if (!GLOB.teleports[id])
		GLOB.teleports[id] = list()
	GLOB.teleports[id] += src

	// Recalculate your list
	pop_valid_list()

	// If you're twoway, notify others
	if (twoway)
		for (var/obj/effect/darkout_teleporter/t in GLOB.teleports[id])
			if (t != src)
				t.pop_valid_list()