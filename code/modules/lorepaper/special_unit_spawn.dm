GLOBAL_LIST_EMPTY(special_cryospawns)

/obj/structure/soldiercryo/special
	icon_state = "cryo_loaded-gray"
	empty_state = "cryo_used-gray"
	density = TRUE
	var/id

/obj/structure/soldiercryo/special/Initialize()
	. = ..()
	if(!length(GLOB.special_cryospawns[id]))
		GLOB.special_cryospawns[id] = list()
	GLOB.special_cryospawns[id] += src

/obj/structure/soldiercryo/special/MouseDrop_T(mob/target, mob/user)
	return

/obj/structure/soldiercryo/special/attackby(obj/item/grab/normal/G, user)
	return

/obj/structure/soldiercryo/special/red
	id = RED_TEAM

/obj/structure/soldiercryo/special/blue
	id = BLUE_TEAM