/obj/structure/table/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	can_plate = 0
	can_reinforce = 0
	flipped = -1

	material = DEFAULT_TABLE_MATERIAL

/obj/structure/table/rack/New()
	..()
	verbs -= /obj/structure/table/verb/do_flip
	verbs -= /obj/structure/table/proc/do_put

/obj/structure/table/rack/Initialize()
	auto_align()
	. = ..()
/*
/obj/structure/table/rack/update_connections()
	return

/obj/structure/table/rack/update_desc()
	return

/obj/structure/table/rack/update_icon()
	return

/obj/structure/table/rack/can_connect()
	return FALSE
*/
/obj/structure/table/rack/holorack/dismantle(obj/item/wrench/W, mob/user)
	to_chat(user, "<span class='warning'>You cannot dismantle \the [src].</span>")
	return

/obj/structure/table/rack/bograck
	name = "strange rack"
	desc ="Must be the color."
	icon = 'icons/obj/objects.dmi'
	icon_state = "bograck"
	can_plate = 0
	can_reinforce = 0
	flipped = 0

/obj/structure/table/rack/dark
	color = COLOR_GRAY40

/obj/structure/table/rack/shelf
	name = "shelf"
	desc = "You can put things on it, actually."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shelf"
	can_plate = 0
	can_reinforce = 0
	flipped = 0

/obj/structure/table/rack/shelf/red
	name = "shelf"
	desc = "You can put things on it, actually."
	icon_state = "shelfred"