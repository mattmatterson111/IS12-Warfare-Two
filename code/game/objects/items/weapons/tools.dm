//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Welding Tool
 * 		Crowbar
 */

/*
 * Wrench
 */
/obj/item/wrench
	name = "wrench"
	desc = "A good, durable combination wrench, with self-adjusting, universal open- and ring-end mechanisms to match a wide variety of nuts and bolts."
	description_info = "This versatile tool is used for dismantling machine frames, anchoring or unanchoring heavy objects like vending machines and emitters, and much more. In general, if you want something to move or stop moving entirely, you ought to use a wrench on it."
	description_fluff = "The classic open-end wrench (or spanner, if you prefer) hasn't changed significantly in shape in over 500 years, though these days they employ a bit of automated trickery to match various bolt sizes and configurations."
	description_antag = "Not only is this handy tool good for making off with machines, but it even makes a weapon in a pinch!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "wrench"
	item_state = "wrench"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 8
	throwforce = 7.0
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 150)
	center_of_mass = "x=17;y=16"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	grab_sound = 'sound/items/handle/wrench_pickup.ogg'
	drop_sound = 'sound/items/handle/wrench_drop.ogg'


/*
 * Screwdriver
 */
/obj/item/screwdriver
	name = "screwdriver"
	desc = "Your archetypal flathead screwdriver, with a nice, heavy polymer handle."
	description_info = "This tool is used to expose or safely hide away cabling. It can open and shut the maintenance panels on vending machines, airlocks, and much more. You can also use it, in combination with a crowbar, to install or remove windows."
	description_fluff = "Screws have not changed significantly in centuries, and neither have the drivers used to install and remove them."
	description_antag = "In the world of breaking and entering, tools like multitools and wirecutters are the bread; the screwdriver is the butter. In a pinch, try targetting someone's eyes and stabbing them with it - it'll really hurt!"
	icon = 'icons/obj/tools.dmi'
	icon_state = "screwdriver"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT | SLOT_EARS
	force = 5
	w_class = ITEM_SIZE_TINY
	throwforce = 3
	throw_speed = 3
	throw_range = 5
	matter = list(DEFAULT_WALL_MATERIAL = 75)
	center_of_mass = "x=16;y=7"
	attack_verb = list("stabbed")
	lock_picking_level = 5
	sharp = TRUE
	grab_sound = 'sound/items/handle/screwdriver_pickup.ogg'
	drop_sound = 'sound/items/handle/screwdriver_drop.ogg'

/obj/item/screwdriver/Initialize()
	switch(pick("red","blue","purple","brown","green","cyan","yellow"))
		if ("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if ("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if ("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if ("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if ("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if ("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if ("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if (prob(75))
		src.pixel_y = rand(0, 16)
	. = ..()

/obj/item/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M) || user.a_intent == "help")
		return ..()
	if(user.zone_sel.selecting != BP_EYES && user.zone_sel.selecting != BP_HEAD)
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)

/*
 * Wirecutters
 */
/obj/item/wirecutters
	name = "wirecutters"
	desc = "A special pair of pliers with cutting edges. Various brackets and manipulators built into the handle allow it to repair severed wiring."
	description_info = "This tool will cut wiring anywhere you see it - make sure to wear insulated gloves! When used on more complicated machines or airlocks, it can not only cut cables, but repair them, as well."
	description_fluff = "With modern alloys, today's wirecutters can snap through cables of astonishing thickness."
	description_antag = "These cutters can be used to cripple the power anywhere on the ship. All it takes is some creativity, and being in the right place at the right time."
	icon = 'icons/obj/tools.dmi'
	icon_state = "cutters"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 3.0
	throw_speed = 2
	throw_range = 9
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 1, TECH_ENGINEERING = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 80)
	center_of_mass = "x=18;y=10"
	attack_verb = list("pinched", "nipped")
	sharp = TRUE
	grab_sound = 'sound/items/handle/wirecutter_pickup.ogg'
	drop_sound = 'sound/items/handle/wirecutter_drop.ogg'

/obj/item/wirecutters/Initialize()
	if(prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"
	. = ..()

/obj/item/wirecutters/attack(mob/living/carbon/C as mob, mob/living/user as mob)
	if(user.a_intent == I_HELP && (C.handcuffed) && (istype(C.handcuffed, /obj/item/handcuffs/cable)))
		usr.visible_message("\The [usr] cuts \the [C]'s restraints with \the [src]!",\
		"You cut \the [C]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		C.handcuffed = null
		if(C.buckled && C.buckled.buckle_require_restraints)
			C.buckled.unbuckle_mob()
		C.update_inv_handcuffed()
		return

	remove_shrapnel(C, user)

	//Tearing out teeth
	if(ishuman(C) && user.zone_sel.selecting == "mouth")
		var/mob/living/carbon/human/H = C
		var/mob/living/carbon/human/teeth_pulling_bitch = user //Fuck you scavs. You know what you did.
		var/obj/item/organ/external/head/O = locate() in H.organs
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & FACE))
				to_chat(teeth_pulling_bitch, "<span class='warning'>You're going to need to remove whatever's covering their mouth first.</span>")
				return
		if(!O || !O.get_teeth())
			to_chat(teeth_pulling_bitch, "<span class='notice'>[H] doesn't have any teeth left!</span>")
			return
		if(!H.stat == DEAD)//If they're dead they're fair game. Otherwise don't pull out your teammates fucking teeth.
			if(teeth_pulling_bitch.warfare_faction == H.warfare_faction)
				to_chat(teeth_pulling_bitch, "<span class='notice'>[H] is on my side, it would be rude to pull out their teeth!</span>") // this is broken?
				return
		if(!teeth_pulling_bitch.doing_something)
			teeth_pulling_bitch.doing_something = 1
			H.visible_message("<span class='danger'>[teeth_pulling_bitch] tries to tear off [H]'s tooth with [src]!</span>",
								"<span class='danger'>[teeth_pulling_bitch] tries to tear off your tooth with [src]!</span>")
			if(do_after(teeth_pulling_bitch, 50, H))
				if(!O || !O.get_teeth())
					teeth_pulling_bitch.doing_something = 0 // Teeth puller is not doing something anymore
					return
				var/obj/item/stack/teeth/E = pick(O.teeth_list)
				if(!E || E.zero_amount())
					teeth_pulling_bitch.doing_something = 0 // Teeth puller is not doing something anymore
					return
				var/obj/item/stack/teeth/T = new E.type(H.loc, 1)
				E.use(1)
				T.add_blood(H)
				E.zero_amount() //Try to delete the teeth
				H.visible_message("<span class='danger'>[teeth_pulling_bitch] tears off [H]'s tooth with [src]!</span>",
								"<span class='danger'>[teeth_pulling_bitch] tears off your tooth with [src]!</span>")

				H.apply_damage(rand(1, 3), BRUTE, O)
				H.custom_pain("[pick("OH GOD YOUR MOUTH HURTS SO BAD!", "OH GOD WHY!", "OH GOD YOUR MOUTH!")]", 100, affecting = O)

				playsound(H, 'sound/effects/gore/trauma3.ogg', 40, 1, -1) //And out it goes.
				GLOB.teeth_lost++

				teeth_pulling_bitch.doing_something = 0
			else
				to_chat(teeth_pulling_bitch, "<span class='notice'>Your attempt to pull out a tooth fails...</span>")
				teeth_pulling_bitch.doing_something = 0
				return
		else
			to_chat(teeth_pulling_bitch, "<span class='notice'>Your attempt to pull out a tooth fails...</span>")
			return

	//..()

/obj/item/proc/remove_shrapnel(mob/living/C as mob, mob/living/user as mob)
	//REMOVE SHRAPNEL! VERY IMPORTANT FOR WARFARE!
	if(user.doing_something)
		return
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		var/mob/living/carbon/human/userr = user
		if(userr.a_intent == I_HELP)
			var/obj/item/organ/external/organ = H.get_organ(userr.zone_sel.selecting)
			for(var/obj/item/O in organ.implants)
				if(istype(O,/obj/item/material/shard/shrapnel))
					H.visible_message("<span class='bnotice'>[userr] starts to remove \the [O.name] with \the [src].</span>")
					userr.doing_something = TRUE
					if(do_after(userr, (backwards_skill_scale(user.SKILL_LEVEL(medical)) * 2.5)))
						userr.my_skills[SKILL(medical)].give_xp(10, user)
						userr.doing_something = FALSE
						for(var/datum/wound/wound in organ.wounds)
							wound.embedded_objects -= O
						organ.implants -= O
						O.forceMove(get_turf(H))
						H.visible_message("<span class='bnotice'>[userr] successfully removes \the [O.name] with \the [src].</span>")
						H.custom_pain("[pick("OW!", "OH GOD WHY!", "THAT HURTS A LOT!")]", 70, affecting = organ)
						playsound(H, 'sound/effects/bullet_remove.ogg', 50)
						return
					else
						userr.doing_something = FALSE
						return

/*
 * Welding Tool
 */
/obj/item/weldingtool
	name = "welding tool"
	icon = 'icons/obj/tools.dmi'
	icon_state = "welder"
	item_state = "welder"
	desc = "A heavy but portable welding gun with its own interchangeable fuel tank. It features a simple toggle switch and a port for attaching an external tank."
	description_info = "Use in your hand to toggle the welder on and off. Hold in one hand and click with an empty hand to remove its internal tank. Click on an object to try to weld it. You can seal airlocks, attach heavy-duty machines like emitters and disposal chutes, and repair damaged walls - these are only a few of its uses. Each use of the welder will consume a unit of fuel. Be sure to wear protective equipment such as goggles, a mask, or certain voidsuit helmets to prevent eye damage. You can refill the welder with a welder tank by clicking on it, but be sure to turn it off first!"
	description_fluff = "One of many tools of ancient design, still used in today's busy world of engineering with only minor tweaks here and there. Compact machinery and innovations in fuel storage have allowed for conveniences like this one-piece, handheld welder to exist."
	description_antag = "You can use a welder to rapidly seal off doors, ventilation ducts, and scrubbers. It also makes for a devastating weapon. Modify it with a screwdriver and stick some metal rods on it, and you've got the beginnings of a flamethrower."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	center_of_mass = "x=14;y=15"
	grab_sound = 'sound/items/handle/weldingtool_pickup.ogg'
	drop_sound = 'sound/items/handle/weldingtool_drop.ogg'

	//Amount of OUCH when it's thrown
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL

	//Cost to make in the autolathe
	matter = list(DEFAULT_WALL_MATERIAL = 70, "glass" = 30)

	//R&D tech level
	origin_tech = list(TECH_ENGINEERING = 1)

	//Welding tool specific stuff
	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)

	var/obj/item/welder_tank/tank = /obj/item/welder_tank // where the fuel is stored

/obj/item/weldingtool/Initialize()
	if(ispath(tank))
		tank = new tank

	//set_extension(src, /datum/extension/base_icon_state, /datum/extension/base_icon_state, icon_state)
	update_icon()

	. = ..()

/obj/item/weldingtool/Destroy()
	if(welding)
		STOP_PROCESSING(SSobj, src)

	if (istype(tank))	// TODO: this is a hack around these causing protolathe init [populate_lathe_recipes] to explode
		QDEL_NULL(tank)
	else
		tank = null

	return ..()

/obj/item/weldingtool/examine(mob/user)
	if(..(user, 0))
		if(tank)
			to_chat(user, "\icon[tank] \The [tank] contains [get_fuel()]/[tank.max_fuel] units of fuel!")
		else
			to_chat(user, "There is no tank attached.")

/obj/item/weldingtool/MouseDrop(atom/over)
	if(!CanMouseDrop(over, usr))
		return

	if(istype(over, /obj/item/weldpack))
		var/obj/item/weldpack/wp = over
		if(wp.welder)
			to_chat(usr, "\The [wp] already has \a [wp.welder] attached.")
		else
			usr.drop_from_inventory(src, wp)
			wp.welder = src
			usr.visible_message("[usr] attaches \the [src] to \the [wp].", "You attach \the [src] to \the [wp].")
			wp.update_icon()
		return

	..()

/obj/item/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if(welding)
		to_chat(user, "<span class='danger'>Stop welding first!</span>")
		return

	if(isScrewdriver(W))
		status = !status
		if(status)
			to_chat(user, "<span class='notice'>You secure the welder.</span>")
		else
			to_chat(user, "<span class='notice'>The welder can now be attached and modified.</span>")
		src.add_fingerprint(user)
		return

	if((!status) && (istype(W,/obj/item/stack/rods)))
		var/obj/item/stack/rods/R = W
		R.use(1)
		var/obj/item/flamethrower/F = new/obj/item/flamethrower(user.loc)
		src.loc = F
		F.weldtool = src
		if (user.client)
			user.client.screen -= src
		if (user.r_hand == src)
			user.remove_from_mob(src)
		else
			user.remove_from_mob(src)
		src.master = F
		src.reset_plane_and_layer()
		user.remove_from_mob(src)
		if (user.client)
			user.client.screen -= src
		src.loc = F
		src.add_fingerprint(user)
		return

	if(istype(W, /obj/item/welder_tank))
		if(tank)
			to_chat(user, "Remove the current tank first.")
			return

		if(W.w_class >= w_class)
			to_chat(user, "\The [W] is too large to fit in \the [src].")
			return

		user.drop_from_inventory(W, src)
		tank = W
		user.visible_message("[user] slots \a [W] into \the [src].", "You slot \a [W] into \the [src].")
		update_icon()
		return

	..()


/obj/item/weldingtool/attack_hand(mob/user as mob)
	if(tank && user.get_inactive_hand() == src)
		if(!welding)
			if(tank.can_remove)
				user.visible_message("[user] removes \the [tank] from \the [src].", "You remove \the [tank] from \the [src].")
				user.put_in_hands(tank)
				tank = null
				update_icon()
			else
				to_chat(user, "\The [tank] can't be removed.")
		else
			to_chat(user, "<span class='danger'>Stop welding first!</span>")

	else
		..()


/obj/item/weldingtool/Process()
	if(welding)
		if(!remove_fuel(0.05))
			setWelding(0)

/obj/item/weldingtool/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && !src.welding)
		if(!tank)
			to_chat(user, "\The [src] has no tank attached!")
			return
		O.reagents.trans_to_obj(tank, tank.max_fuel)
		to_chat(user, "<span class='notice'>You refuel \the [tank].</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return
	if (src.welding)
		remove_fuel(1)
		var/turf/location = get_turf(user)
		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, 1)
	return


/obj/item/weldingtool/attack_self(mob/user as mob)
	setWelding(!welding, usr)
	return

//Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return tank ? tank.reagents.get_reagent_amount(/datum/reagent/fuel) : 0


//Removes fuel from the welding tool. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/weldingtool/proc/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!welding)
		return 0
	if(get_fuel() >= amount)
		burn_fuel(amount)
		if(M)
			eyecheck(M)
		return 1
	else
		if(M)
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
		return 0

/obj/item/weldingtool/proc/burn_fuel(var/amount)
	if(!tank)
		return

	var/mob/living/in_mob = null

	//consider ourselves in a mob if we are in the mob's contents and not in their hands
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if(!(L.l_hand == src || L.r_hand == src))
			in_mob = L

	if(in_mob)
		amount = max(amount, 2)
		tank.reagents.trans_type_to(in_mob, /datum/reagent/fuel, amount)
		in_mob.IgniteMob()

	else
		tank.reagents.remove_reagent(/datum/reagent/fuel, amount)
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700, 5)

//Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return src.welding

/obj/item/weldingtool/get_storage_cost()
	if(isOn())
		return ITEM_SIZE_NO_CONTAINER
	return ..()

/obj/item/weldingtool/update_icon()
	..()

	//var/datum/extension/base_icon_state/bis = get_extension(src, /datum/extension/base_icon_state)
	icon_state = welding ? "welder1" : "welder"
	item_state = welding ? "welder1" : "welder"

	underlays.Cut()
	/*
	if(tank)
		var/image/tank_image = image(tank.icon, icon_state = tank.icon_state)
		tank_image.pixel_z = 0
		underlays += tank_image
	*/
	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weldingtool/proc/setWelding(var/set_welding, var/mob/M)
	if(!status)	return

	//If we're turning it on
	if(set_welding && !welding)
		if (get_fuel() > 0)
			if(M)
				to_chat(M, "<span class='notice'>You switch the [src] on.</span>")
				M.visible_message("<span class='danger'>\The [src] turns on.</span>")
				playsound(M, 'sound/items/welderactivate.ogg', 100)
			src.force = 15
			src.damtype = "fire"
			welding = 1
			update_icon()
			START_PROCESSING(SSobj, src)
		else
			if(M)
				to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return
	//Otherwise
	else if(!set_welding && welding)
		STOP_PROCESSING(SSobj, src)
		if(M)
			to_chat(M, "<span class='notice'>You switch \the [src] off.</span>")
			M.visible_message("<span class='warning'>\The [src] turns off.</span>")
			playsound(M, 'sound/items/welderdeactivate.ogg', 100)
		src.force = 3
		src.damtype = "brute"
		src.welding = 0
		update_icon()

//Decides whether or not to damage a player's eyes based on what they're wearing as protection
//Note: This should probably be moved to mob
/obj/item/weldingtool/proc/eyecheck(mob/user as mob)
	if(!iscarbon(user))	return 1
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/internal/eyes/E = H.internal_organs_by_name[BP_EYES]
		if(!E)
			return
		var/safety = H.eyecheck()
		switch(safety)
			if(FLASH_PROTECTION_MODERATE)
				to_chat(H, "<span class='warning'>Your eyes sting a little.</span>")
				//E.damage += rand(1, 2)
				//if(E.damage > 12)
				H.eye_blurry += rand(3,6)
			if(FLASH_PROTECTION_NONE)
				to_chat(H, "<span class='warning'>Your eyes burn.</span>")
				H.eye_blurry += rand(4,10)
				//E.damage += rand(2, 4)
				//if(E.damage > 10)
				//	E.damage += rand(4,10)
			if(FLASH_PROTECTION_REDUCED)
				to_chat(H, "<span class='danger'>Your equipment intensifies the welder's glow. Your eyes itch and burn severely.</span>")
				H.eye_blurry += rand(12,20)
				//E.damage += rand(12, 16)
		/*
		if(safety<FLASH_PROTECTION_MAJOR)
			if(E.damage > 10)
				to_chat(user, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")

			if (E.damage >= E.min_broken_damage)
				to_chat(H, "<span class='danger'>You go blind!</span>")
				H.sdisabilities |= BLIND
			else if (E.damage >= E.min_bruised_damage)
				to_chat(H, "<span class='danger'>You go blind!</span>")
				H.eye_blind = 5
				H.eye_blurry = 5
				H.disabilities |= NEARSIGHTED
				spawn(100)
					H.disabilities &= ~NEARSIGHTED
		*/

/obj/item/welder_tank
	name = "welding fuel tank"
	desc = "An interchangeable fuel tank meant for a welding tool."
	icon = 'icons/obj/tools.dmi'
	icon_state = "fuel_m"
	w_class = ITEM_SIZE_SMALL
	var/max_fuel = 20
	var/can_remove = 1

/obj/item/welder_tank/Initialize()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	. = ..()

/obj/item/welder_tank/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1)
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, "<span class='notice'>You refuel \the [src].</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return

/obj/item/weldingtool/mini
	name = "miniature welding tool"
	icon_state = "welder_s"
	item_state = "welder"
	desc = "A smaller welder, meant for quick or emergency use."
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(DEFAULT_WALL_MATERIAL = 15, "glass" = 5)
	w_class = ITEM_SIZE_SMALL
	tank = /obj/item/welder_tank/mini

/obj/item/welder_tank/mini
	name = "small welding fuel tank"
	icon_state = "fuel_s"
	w_class = ITEM_SIZE_TINY
	max_fuel = 5
	can_remove = 0

/obj/item/weldingtool/largetank
	name = "industrial welding tool"
	icon_state = "welder_l"
	item_state = "welder"
	desc = "A heavy-duty portable welder, made to ensure it won't suddenly go cold on you."
	origin_tech = list(TECH_ENGINEERING = 2)
	matter = list(DEFAULT_WALL_MATERIAL = 70, "glass" = 60)
	w_class = ITEM_SIZE_LARGE
	tank = /obj/item/welder_tank/large

/obj/item/welder_tank/large
	name = "large welding fuel tank"
	icon_state = "fuel_l"
	w_class = ITEM_SIZE_NORMAL
	max_fuel = 40

/obj/item/weldingtool/hugetank
	name = "upgraded welding tool"
	icon_state = "welder_h"
	item_state = "welder"
	desc = "A sizable welding tool with room to accomodate the largest of fuel tanks."
	w_class = ITEM_SIZE_HUGE
	origin_tech = list(TECH_ENGINEERING = 3)
	matter = list(DEFAULT_WALL_MATERIAL = 70, "glass" = 120)
	tank = /obj/item/welder_tank/huge

/obj/item/welder_tank/huge
	name = "huge welding fuel tank"
	icon_state = "fuel_h"
	w_class = ITEM_SIZE_LARGE
	max_fuel = 80

/obj/item/weldingtool/experimental
	name = "experimental welding tool"
	icon_state = "welder_l"
	item_state = "welder"
	desc = "This welding tool feels heavier in your possession than is normal. There appears to be no external fuel port."
	w_class = ITEM_SIZE_LARGE
	origin_tech = list(TECH_ENGINEERING = 4, TECH_PHORON = 3)
	matter = list(DEFAULT_WALL_MATERIAL = 70, "glass" = 120)
	tank = /obj/item/welder_tank/experimental

/obj/item/welder_tank/experimental
	name = "experimental welding fuel tank"
	icon_state = "fuel_x"
	w_class = ITEM_SIZE_NORMAL
	max_fuel = 40
	can_remove = 0
	var/last_gen = 0

/obj/item/welder_tank/experimental/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/welder_tank/experimental/Destroy()
	STOP_PROCESSING(SSobj, src)

/obj/item/welder_tank/experimental/Process()
	var/cur_fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
	if(cur_fuel < max_fuel)
		var/gen_amount = ((world.time-last_gen)/25)
		reagents.add_reagent(/datum/reagent/fuel, gen_amount)
		last_gen = world.time

/obj/item/weldingtool/attack(mob/living/M, mob/living/user, target_zone)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.organs_by_name[target_zone]

		if(!S || !(S.robotic >= ORGAN_ROBOT) || user.a_intent != I_HELP)
			return ..()

		if(!welding)
			to_chat(user, "<span class='warning'>You'll need to turn [src] on to patch the damage on [M]'s [S.name]!</span>")
			return 1

		if(S.robo_repair(15, BRUTE, "some dents", src, user))
			remove_fuel(1, user)

	else
		return ..()

/*
 * Crowbar
 */

/obj/item/crowbar
	name = "crowbar"
	desc = "A heavy crowbar of solid steel, good and solid in your hand."
	description_info = "Crowbars have countless uses: click on floor tiles to pry them loose. Use alongside a screwdriver to install or remove windows. Force open emergency shutters, or depowered airlocks. Open the panel of an unlocked APC. Pry a computer's circuit board free. And much more!"
	description_fluff = "As is the case with most standard-issue tools, crowbars are a simple and timeless design, the only difference being that advanced materials like plasteel have made them uncommonly tough."
	description_antag = "Need to bypass a bolted door? You can use a crowbar to pry the electronics out of an airlock, provided that it has no power and has been welded shut."
	icon = 'icons/obj/tools.dmi'
	icon_state = "crowbar"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 7.0
	throwforce = 7.0
	throw_range = 3
	item_state = "crowbar"
	hitsound = 'sound/weapons/crowbarhit2.ogg' //hitsound = 'sound/weapons/crowhit.ogg'//This sound effect has 0 punch, makes crowbars feel less powerful.
	grab_sound = 'sound/items/handle/crowbar_pickup.ogg'
	drop_sound = 'sound/items/handle/crowbar_drop.ogg'
	w_class = ITEM_SIZE_NORMAL
	origin_tech = list(TECH_ENGINEERING = 1)
	matter = list(DEFAULT_WALL_MATERIAL = 140)
	center_of_mass = "x=16;y=20"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	block_chance = 15
	parry_sounds = list('sound/weapons/blunt_parry1.ogg', 'sound/weapons/blunt_parry2.ogg', 'sound/weapons/blunt_parry3.ogg')


/obj/item/crowbar/red
	icon_state = "red_crowbar"
	item_state = "crowbar_red"

/obj/item/crowbar/prybar
	name = "pry bar"
	desc = "A steel bar with a wedge. It comes in a variety of configurations - collect them all."
	icon_state = "prybar"
	item_state = "crowbar"
	force = 4.0
	throwforce = 6.0
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(DEFAULT_WALL_MATERIAL = 80)

/obj/item/crowbar/prybar/Initialize()
	icon_state = "prybar[pick("","_red","_green","_aubergine","_blue")]"
	. = ..()

/obj/item/handle_shield(mob/living/user, var/damage, atom/damage_source = null, mob/attacker = null, var/def_zone = null, var/attack_text = "the attack")
	if(default_sword_parry(user, damage, damage_source, attacker, def_zone, attack_text))
		return 1
	return 0