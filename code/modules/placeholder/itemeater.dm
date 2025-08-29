/obj/structure/warfare_itemeater
	name = "Hand eater"
	desc = "Now accepting dogtags, helmets, teeth and souls at a higher price!"
	icon = 'icons/obj/warfare.dmi'
	icon_state = "ie"
	anchored = TRUE
	var/id = "NEUTRAL"
	var/starting_value = 500

/obj/structure/warfare_itemeater/New()
	if(!GLOB.faction_dosh[id])
		GLOB.faction_dosh[id] = starting_value

/obj/structure/warfare_itemeater/red
	icon_state = "ie-r"
	id = RED_TEAM

/obj/structure/warfare_itemeater/blue
	icon_state = "ie-b"
	id = RED_TEAM

/obj/structure/warfare_itemeater/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/spacecash))
		var/obj/item/spacecash/dolla = O
		if(dolla.worth <= 0)
			to_chat(user, "\icon[src]You cannot insert that into the hatch.")
			flick("[icon_state]_o", src)
		else
			to_chat(user, "\icon[src]You insert [O.name] into the hatch.")
			GLOB.faction_dosh[id] += dolla.worth
			qdel(O)
			flick("[icon_state]_o", src)
			playsound(src, 'sound/effects/thehatchin.ogg', 75, 0.25)
			return
	else if(istype(O, /obj/item/stack/teeth))
		var/obj/item/stack/teeth/toof = O
		if(toof.amount <= 0)
			qdel(toof) // no you dont get to insert 0 teeth for cash.
			flick("[icon_state]_o", src)
			return
		var/to_grant = 0
		for(var/i = 1, i <= toof.amount, i++)
			to_grant += 5
		qdel(toof)
		GLOB.faction_dosh[id] += to_grant
		playsound(src, 'sound/effects/thehatchin.ogg', 75, 0.25)
		flick("[icon_state]_o", src)
		return
	else if(istype(O, /obj/item/clothing/head/helmet/redhelmet) && id == BLUE_TEAM || istype(O, /obj/item/clothing/head/helmet/bluehelmet) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 12
		qdel(O)
		playsound(src, 'sound/effects/thehatchin.ogg', 75, 0.25)
		flick("[icon_state]_o", src)
		return

	else if(istype(O, /obj/item/card/id/dog_tag/red) && id == BLUE_TEAM || istype(O, /obj/item/card/id/dog_tag/blue) && id == RED_TEAM ) // meh
		GLOB.faction_dosh[id] += 12
		qdel(O)
		playsound(src, 'sound/effects/thehatchin.ogg', 75, 0.25)
		flick("[icon_state]_o", src)
		return