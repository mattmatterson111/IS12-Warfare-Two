/*
 * The 'fancy' path is for objects like candle boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 *
 * Contains:
 *		Egg Box
 *		Candle Box
 *		Crayon Box
 *		Cigarette Box
 */

/obj/item/storage/fancy
	item_state = "syringe_kit" //placeholder, many of these don't have inhands
	var/obj/item/key_type //path of the key item that this "fancy" container is meant to store
	var/opened = 0 //if an item has been removed from this container

/obj/item/storage/fancy/remove_from_storage()
	. = ..()
	if(!opened && .)
		opened = 1
		update_icon()


/obj/item/storage/fancy/update_icon()
	if(!opened)
		src.icon_state = initial(icon_state)
	else
		var/key_count = count_by_type(contents, key_type)
		src.icon_state = "[initial(icon_state)][key_count]"

/obj/item/storage/fancy/examine(mob/user)
	if(!..(user, 1))
		return

	var/key_name = initial(key_type.name)
	if(!contents.len)
		to_chat(user, "There are no [key_name]s left in the box.")
	else
		var/key_count = count_by_type(contents, key_type)
		to_chat(user, "There [key_count == 1? "is" : "are"] [key_count] [key_name]\s in the box.")

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food.dmi'
	icon_state = "eggbox"
	name = "egg box"
	storage_slots = 12
	max_w_class = ITEM_SIZE_SMALL
	w_class = ITEM_SIZE_NORMAL

	key_type = /obj/item/reagent_containers/food/snacks/egg
	can_hold = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/boiledegg
		)

	startswith = list(/obj/item/reagent_containers/food/snacks/egg = 12)

/obj/item/storage/fancy/egg_box/empty
	startswith = null


/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox"
	opened = 1 //no closed state
	throwforce = 2
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 5
	slot_flags = SLOT_BELT

	key_type = /obj/item/flame/candle
	startswith = list(/obj/item/flame/candle = 5)

/*
 * Crayon Box
 */

/obj/item/storage/fancy/crayons
	name = "box of crayons"
	desc = "A box of crayons for all your rune drawing needs."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "crayonbox"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 6

	key_type = /obj/item/pen/crayon
	startswith = list(
		/obj/item/pen/crayon/red,
		/obj/item/pen/crayon/orange,
		/obj/item/pen/crayon/yellow,
		/obj/item/pen/crayon/green,
		/obj/item/pen/crayon/blue,
		/obj/item/pen/crayon/purple,
		)

/obj/item/storage/fancy/crayons/update_icon()
	overlays = list() //resets list
	overlays += image('icons/obj/crayons.dmi',"crayonbox")
	for(var/obj/item/pen/crayon/crayon in contents)
		overlays += image('icons/obj/crayons.dmi',crayon.colourName)

////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "pack of Smokey Boys"
	desc = "A ubiquitous brand of cigarettes. As mild and flavorless as it gets."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigpacket"
	item_state = "cigpacket"
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 6
	throwforce = 2
	slot_flags = SLOT_BELT

	key_type = /obj/item/clothing/mask/smokable/cigarette
	startswith = list(/obj/item/clothing/mask/smokable/cigarette = 6)

/obj/item/storage/fancy/cigarettes/New()
	..()
	atom_flags |= ATOM_FLAG_NO_REACT|ATOM_FLAG_OPEN_CONTAINER
	create_reagents(5 * max_storage_space)//so people can inject cigarettes without opening a packet, now with being able to inject the whole one

/obj/item/storage/fancy/cigarettes/remove_from_storage(obj/item/W as obj, atom/new_location)
	// Don't try to transfer reagents to lighters
	if(istype(W, /obj/item/clothing/mask/smokable/cigarette))
		var/obj/item/clothing/mask/smokable/cigarette/C = W
		reagents.trans_to_obj(C, (reagents.total_volume/contents.len))
	..()

/obj/item/storage/fancy/cigarettes/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if(M == user && user.zone_sel.selecting == BP_MOUTH && contents.len > 0 && !user.wear_mask)
		// Find ourselves a cig. Note that we could be full of lighters.
		var/obj/item/clothing/mask/smokable/cigarette/cig = null
		for(var/obj/item/clothing/mask/smokable/cigarette/C in contents)
			cig = C
			break

		if(cig == null)
			to_chat(user, "<span class='notice'>Looks like the packet is out of cigarettes.</span>")
			return

		// Instead of running equip_to_slot_if_possible() we check here first,
		// to avoid dousing cig with reagents if we're not going to equip it
		if(!cig.mob_can_equip(user, slot_wear_mask))
			return

		// We call remove_from_storage first to manage the reagent transfer and
		// UI updates.
		remove_from_storage(cig, null)
		user.equip_to_slot(cig, slot_wear_mask)

		reagents.maximum_volume = 5 * contents.len
		to_chat(user, "<span class='notice'>You take a cigarette out of the pack.</span>")
		update_icon()
	else
		..()

/obj/item/storage/fancy/cigarettes/heavy
	name = "Heavy Industry Unfiltered Cigs"
	desc = "For when all the cigarettes with actual flavor are gone."
	icon_state = "TOHAHeavyIndustriesCigPacket"
	item_state = "TOHAHeavyIndustriesCigPacket"
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/heavy = 6)

// New exciting ways to kill your lungs! - Earthcrusher //

/obj/item/storage/fancy/cigarettes/luckystars
	name = "pack of Brouzefs"
	desc = "Captain Brouzef's famous cigarettes. It's rumored they're used as currency in the shittier parts of the planet."
	icon_state = "LSpacket"
	item_state = "LSpacket"
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/luckystars = 6)

/obj/item/storage/fancy/cigarettes/jerichos
	name = "pack of Roacheyes"
	desc = "Typically seen dangling from the lips of soldiers. Feels like warm liquid death down your lungs."
	icon_state = "Jpacket"
	item_state = "Jpacket"
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/jerichos = 6)

/obj/item/storage/fancy/cigarettes/carcinomas
	name = "pack of Tannhauser Gates"
	desc = "Noone really knows who Tannhauser Gate was, or why he sold cigarettes."
	icon_state = "CApacket"
	item_state = "CApacket"
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/carcinomas = 6)

//cigarillos
/obj/item/storage/fancy/cigarettes/cigarillo
	name = "pack of Redlin Bull cigarillos"
	desc = "A branded little cigars, favored by the guleans for their pleasant aroma. Machine made in Redlin."
	icon_state = "CRpacket"
	item_state = "CRpacket"
	key_type = /obj/item/clothing/mask/smokable/cigarette/cigarillo
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/cigarillo = 6)

/obj/item/storage/fancy/cigar
	name = "Presidential Reserve cigar case"
	desc = "A case for holding your cigars when you are not smoking them."
	icon_state = "cigarcase"
	item_state = "cigarcase"
	icon = 'icons/obj/cigarettes.dmi'
	w_class = ITEM_SIZE_SMALL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = 5
	throwforce = 2
	slot_flags = SLOT_BELT
	storage_slots = 5

	key_type = /obj/item/clothing/mask/smokable/cigarette/cigar
	startswith = list(/obj/item/clothing/mask/smokable/cigarette/cigar = 5)

/obj/item/storage/fancy/cigar/New()
	..()
	atom_flags |= ATOM_FLAG_NO_REACT
	create_reagents(10 * storage_slots)

/obj/item/storage/fancy/cigar/remove_from_storage(obj/item/W as obj, atom/new_location)
	var/obj/item/clothing/mask/smokable/cigarette/cigar/C = W
	if(!istype(C)) return
	reagents.trans_to_obj(C, (reagents.total_volume/contents.len))
	..()

/*
 * Vial Box
 */

/obj/item/storage/fancy/vials
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox"
	name = "vial storage box"
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_TINY
	storage_slots = 12

	key_type = /obj/item/reagent_containers/glass/beaker/vial
	startswith = list(/obj/item/reagent_containers/glass/beaker/vial = 12)

/obj/item/storage/fancy/vials/update_icon()
	var/key_count = count_by_type(contents, key_type)
	src.icon_state = "[initial(icon_state)][Floor(key_count/2)]"

/*
 * Not actually a "fancy" storage...
 */
/obj/item/storage/lockbox/vials
	name = "secure vial storage box"
	desc = "A locked box for keeping things away from children."
	icon = 'icons/obj/vialbox.dmi'
	icon_state = "vialbox0"
	item_state = "syringe_kit"
	w_class = ITEM_SIZE_NORMAL
	max_w_class = ITEM_SIZE_TINY
	max_storage_space = null
	storage_slots = 12
	req_access = list(access_virology)

/obj/item/storage/lockbox/vials/New()
	..()
	update_icon()

/obj/item/storage/lockbox/vials/update_icon()
	var/total_contents = count_by_type(contents, /obj/item/reagent_containers/glass/beaker/vial)
	src.icon_state = "vialbox[Floor(total_contents/2)]"
	src.overlays.Cut()
	if (!broken)
		overlays += image(icon, src, "led[locked]")
		if(locked)
			overlays += image(icon, src, "cover")
	else
		overlays += image(icon, src, "ledb")
	return

/obj/item/storage/lockbox/vials/attackby(obj/item/W as obj, mob/user as mob)
	. = ..()
	update_icon()
