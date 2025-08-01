/* Copyright (C) The interbay dev team - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 *
 * Proprietary and confidential
 * Do not modify or remove this header.
 *
 * Written by Kyrah Abattoir <git@kyrahabattoir.com>, August 2018
 */

//This is a special baseclass to equip machineries and other static objects with
//a standard backpack style storage, it does so by overriding the adjacency check
//allowing to manipulate the container's inventory despite not being on a player
//or a turf.

/obj/item/storage/special
	name = "/obj/item/storage/special"
	desc = "base storage for storage machines & structures"
	w_class = ITEM_SIZE_NO_CONTAINER
	max_w_class = ITEM_SIZE_GARGANTUAN //you prolly want to change this on subclasses.
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	//storage_slots = 1
	use_sound = null
	close_sound = null
	var/atom/holder

//overrides item:Adjacent() so we can drop down one level
/obj/item/storage/special/Adjacent(var/atom/neighbor)
	return loc.Adjacent(neighbor)

/obj/item/storage/special/attack_hand(mob/user as mob)
	open(user)

/obj/item/storage/special/AltClick(mob/user as mob)
	open(user)

/obj/item/storage/special/gather_all(var/turf/T)
	for(var/obj/item/I in T)
		if(can_be_inserted(I, null, 1))
			handle_item_insertion(I, 1, 1) // First 1 is no messages, second 1 is no ui updates
		else
			continue

//Use this machine as a base class it's pretty simple
/obj/machinery/storage/
	name = "/obj/machinery/storage/"
	desc = "baseclass for storage enabled machinery"
	icon = 'icons/obj/closet.dmi'
	icon_state = "cabinet_closed"
	var/mob/fuck
	var/open_state
	var/obj/item/storage/special/inventory
	var/sound_override

/obj/machinery/storage/New()
	inventory = new /obj/item/storage/special()
	inventory.holder = src
	inventory.loc = src   //VERY IMPORTANT
	inventory.name = name //Not strictly needed but this affects the text description when players insert items inside the storage.

/obj/machinery/storage/Destroy()
	qdel(inventory)
	..()

/obj/machinery/storage/proc/open(var/obj/item/I, var/autoclose)
	if(I)
		if(!inventory.can_be_inserted(I, null, 1))
			return
	if(!open_state)
		return
	icon_state = open_state
	if(!autoclose)
		return
	spawn(autoclose SECONDS)
		icon_state = initial(icon_state)

/obj/machinery/storage/proc/close()
	icon_state = initial(icon_state)
	GLOB.moved_event.unregister(fuck, src)
	fuck = null


//fowards attack_hand
/obj/machinery/storage/attack_hand(mob/user as mob)
	if(CanPhysicallyInteract(user))
		inventory.attack_hand(user)
		open(null,null)
		fuck = user
		GLOB.moved_event.register(fuck, src, /obj/machinery/storage/proc/close)


//fowards attackby
/obj/machinery/storage/attackby(obj/item/W as obj, mob/user as mob)
	if(!CanPhysicallyInteract(user))
		return
	if(sound_override)
		W.bag_place_sound = sound_override
		inventory.attackby(W, user)
		W.bag_place_sound = initial(W.bag_place_sound)
	open(W, 1)


//Use this machine as a base class it's pretty simple
/obj/structure/storage/
	name = "/obj/structure/storage/"
	desc = "baseclass for storage enabled structures"
	icon = 'icons/obj/closet.dmi'
	icon_state = "cabinet_closed"
	var/mob/fuck
	var/open_state
	var/obj/item/storage/special/inventory
	var/sound_override

/obj/structure/storage/New()
	inventory = new /obj/item/storage/special()
	inventory.holder = src
	inventory.loc = src   //VERY IMPORTANT
	inventory.name = name //Not strictly needed but this affects the text description when players insert items inside the storage.

/obj/structure/storage/Destroy()
	qdel(inventory)
	..()

/obj/structure/storage/proc/open(var/obj/item/I, var/autoclose)
	if(I)
		if(!inventory.can_be_inserted(I, null, 1))
			return
	if(!open_state)
		return
	icon_state = open_state
	if(!autoclose)
		return
	spawn(autoclose SECONDS)
		icon_state = initial(icon_state)

/obj/structure/storage/proc/close()
	icon_state = initial(icon_state)
	GLOB.moved_event.unregister(fuck, src)
	fuck = null


//fowards attack_hand
/obj/structure/storage/attack_hand(mob/user as mob)
	if(CanPhysicallyInteract(user))
		inventory.attack_hand(user)
		open(null,null)
		fuck = user
		GLOB.moved_event.register(fuck, src, /obj/structure/storage/proc/close)


//fowards attackby
/obj/structure/storage/attackby(obj/item/W as obj, mob/user as mob)
	if(!CanPhysicallyInteract(user))
		return
	if(sound_override)
		W.bag_place_sound = sound_override
		inventory.attackby(W, user)
		W.bag_place_sound = initial(W.bag_place_sound)
	open(W, 1)

/obj/structure/storage/AltClick(mob/user as mob)
	attack_hand(user)

/obj/structure/storage/cabinet
	name = "Filing cabinet"
	desc = "Dusty.. probably has the files of your great-great-great-grandfather.."
	icon = 'icons/obj/storagestructures.dmi'
	icon_state = "filing"
	open_state = "filing_open"
	sound_override = 'sound/effects/cabinetplace.ogg'
	anchored = TRUE
	density = TRUE

/obj/structure/storage/cabinet/Initialize()
	. = ..()
	inventory.max_storage_space = DEFAULT_BOX_STORAGE
	inventory.use_sound = 'sound/effects/cabinetopen.ogg'
	inventory.close_sound = 'sound/effects/cabinetclose.ogg'
	inventory.gather_all(get_turf(src))