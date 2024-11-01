/obj/item/key
	name = "key"
	desc = "Used to unlock things."
	icon = 'icons/obj/items.dmi'
	icon_state = "keys"
	w_class = 1
	grab_sound = 'sound/effects/key_pickup.ogg'
	drop_sound = 'sound/effects/key_drop.ogg'
	var/key_data = ""

/obj/item/key/New(var/newloc,var/data)
	if(data)
		key_data = data
	..(newloc)

/obj/item/key/proc/get_data(var/mob/user)
	return key_data

/obj/item/key/soap
	name = "soap key"
	desc = "a fragile key made using a bar of soap."
	var/uses = 0

/obj/item/key/soap/get_data(var/mob/user)
	uses--
	if(uses == 1)
		to_chat(user, "<span class='warning'>\The [src] is going to break soon!</span>")
	else if(uses <= 0)
		user.drop_item(src)
		to_chat(user, "<span class='warning'>\The [src] crumbles in your hands.</span>")
		qdel(src)
	return ..()


/obj/item/key/inn1
	key_data = "inn1"

/obj/item/key/inn1
	key_data = "inn2"

/obj/item/masterkey
	slot_flags = SLOT_ID|SLOT_BELT
	icon = 'icons/obj/items.dmi'
	icon_state = "keyring"
	name = "keyring"
	desc = "This holds your keys. Use this when you want to unlock something, dummy."
	w_class = 2

	New()
		update_icon()

/obj/item/masterkey/examine(mob/user)
	if (locate(src) in get_step(user, user.dir) || user.contents.Find(src))
		to_chat(user, "<span class = 'notice'>[desc]. Right now it's holding [print_keys()].</span>")
	..()

/obj/item/masterkey/proc/print_keys()
	if (contents.len == 0)
		return "nothing"
	else
		var/ret = ""
		for (var/obj/item/key/key in contents)
			ret = "[ret],[key]"
		return ret


/obj/item/masterkey/update_icon()
	switch (contents.len)
		if (0)
			icon_state = "keyring"
		if (1)
			icon_state = "keyring-1"
		if (2)
			icon_state = "keyring-2"
		if (3)
			icon_state = "keyring-3"
		if (4)
			icon_state = "keyring-4"
		if (5 to INFINITY)
			icon_state = "keyring-5"

/obj/item/masterkey/attack_self(mob/user)
	if (!contents.len)
		return
	else
		var/which
		var/obj/item/key/key
		which = input("Take out which key?", "Key Storage", key) as null|anything in contents
		if(which)
			contents -= which
			user.put_in_hands(which)
			update_icon()
			visible_message("<span class = 'notice'>[user] takes a key from their keychain.</span>", "<span class = 'notice'>You take out [which].</span>")

/obj/item/masterkey/attackby(obj/item/I as obj, mob/user as mob)
	if (istype(I, /obj/item/key))
		var/obj/item/key/key = I
		if(!user.unEquip(I))
			return
		I.forceMove(src)
		contents += key
		update_icon()
		visible_message("<span class = 'notice'>[user] puts a key in their keychain.</span>", "<span class = 'notice'>You put a key in your keychain.</span>")

/obj/item/masterkey/Initialize()
	. = ..()
	update_icon()

/obj/item/masterkey/inn/New()
	..()
	new /obj/item/key/inn1 (src)
	//new /obj/item/key/inn2 (src)
	update_icon()