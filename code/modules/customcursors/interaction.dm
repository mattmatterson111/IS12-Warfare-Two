#define INTERACTIVE 'icons/misc/interactive_cursor.dmi'
#define DROP 'icons/misc/drop_cursor.dmi'
#define SHARP 'icons/misc/sword_cursor.dmi'
#define EXAMINE 'icons/misc/examine_cursor.dmi'

/atom/proc/getCursor(var/mob/user, var/hand)
	return 0

/obj/item/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE
	return 0

/obj/machinery/door/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE
	return 0

/obj/machinery/door/blast/getCursor(mob/user, hand)
	return 0

/obj/structure/closet/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user))
		return INTERACTIVE
	return 0

/obj/structure/curtain/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE
	return 0

/obj/machinery/vending/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE
	return 0

/obj/item/ammo_box/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && istype(hand, handful_type))
		return DROP
	return . = ..()

/obj/structure/destruction_computer/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE
	return 0

/obj/item/reagent_containers/food/snacks/warfare/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && istype(hand, /obj/item/material/sword/combat_knife))
		if(!is_open_container())
			return SHARP
	return . = ..()

/obj/structure/factionbanner/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user) && !hand)
		return INTERACTIVE

/mob/getCursor(mob/user, hand)
	if(CanPhysicallyInteract(user))
		if(user.a_intent == I_HURT)
			if(istype(hand, /obj/item/material/sword/combat_knife) || istype(hand, /obj/item/shovel))
				return SHARP
			else
				return DROP
		else if(user.a_intent == I_HELP)
			if(!hand)
				if(user == src)
					return EXAMINE
				else
					return INTERACTIVE
		else if(user.a_intent == I_GRAB || user.a_intent == I_DISARM)
			if(user != src && !hand)
				return INTERACTIVE
	return . = ..()

/obj/structure/storage/getCursor(mob/user, hand)
	return INTERACTIVE

#undef INTERACTIVE
#undef DROP
#undef SHARP
#undef EXAMINE