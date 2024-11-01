/obj/item/device/binoculars

	name = "binoculars"
	desc = "A pair of binoculars."
	icon_state = "binoculars"

	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 5.0
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	var/warning


/obj/item/device/binoculars/attack_self(mob/user)
	zoom(user)
	if(!warning)
		to_chat(user, SPAN_DANGER("Yeah. I know the UI is pretty :B:roken. Poke me abt it sometime."))
		warning = TRUE

/obj/item/device/binoculars/equipped(var/mob/user, var/slot)
	..()
	if(zoom)
		zoom(user)