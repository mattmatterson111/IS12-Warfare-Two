/obj/item/gun/projectile/revolver
	name = "revolver"
	desc = "The Lumoco Arms HE Colt is a choice revolver for when you absolutely, positively need to put a hole in the other guy. Uses .357 ammo."
	icon_state = "cptrevolver"
	item_state = "crevolver"
	caliber = "357"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	handle_casings = CYCLE_CASINGS
	max_shells = 6
	fire_delay = 6.75 //Revolvers are naturally slower-firing
	ammo_type = /obj/item/ammo_casing/a357
	var/chamber_offset = 0 //how many empty chambers in the cylinder until you hit a round
	unload_sound 	= 'sound/weapons/guns/interact/rev_newempty.ogg'//'sound/weapons/guns/interact/rev_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/rev_magin.ogg'
	bulletinsert_sound 	= "revolver_reload"//'sound/weapons/guns/interact/rev_magin.ogg'
	fire_sound = "revolver_fire"

/obj/item/gun/projectile/revolver/cpt
	name = "Captain's Special"
	desc = "The sort of weapon usually found on nobility, such as captains or commandants."
	icon_state = "cptrevolver"
	item_state = "crevolver"

/obj/item/gun/projectile/revolver/cpt/magistrate
	name = "Commandant's Special"

/obj/item/gun/projectile/revolver/attack_self(mob/user)
	. = ..()
	unload_ammo(usr, allow_dump=TRUE)

/obj/item/gun/projectile/revolver/verb/spin_cylinder()
	set name = "Spin cylinder"
	set desc = "Fun when you're bored out of your skull."
	set category = "Object"

	chamber_offset = 0
	visible_message("<span class='warning'>\The [usr] spins the cylinder of \the [src]!</span>", \
	"<span class='notice'>You hear something metallic spin and click.</span>")
	playsound(src.loc, 'sound/weapons/revolver_spin.ogg', 100, 1)
	loaded = shuffle(loaded)
	if(rand(1,max_shells) > loaded.len)
		chamber_offset = rand(0,max_shells - loaded.len)

/obj/item/gun/projectile/revolver/consume_next_projectile()
	if(chamber_offset)
		chamber_offset--
		return
	return ..()

/obj/item/gun/projectile/revolver/load_ammo(var/obj/item/A, mob/user)
	chamber_offset = 0
	return ..()

/obj/item/gun/projectile/revolver/mateba
	name = "mateba"
	icon_state = "mateba"
	caliber = ".50"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/a50

/obj/item/gun/projectile/revolver/detective
	name = "revolver"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	icon_state = "detective"
	max_shells = 6
	caliber = "38"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun. If you're the detective."

	var/mob/M = usr
	if(!M.mind)	return 0
	if(!M.mind.assigned_role == "Detective")
		to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
		return 0

	var/input = sanitizeSafe(input("What do you want to name the gun?", ,""), MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		SetName(input)
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1

// Blade Runner pistol.
/obj/item/gun/projectile/revolver/deckard
	name = "Deckard .44"
	desc = "A custom-built revolver, based off the semi-popular Detective Special model."
	icon_state = "deckard-empty"
	ammo_type = /obj/item/ammo_magazine/c38/rubber

/obj/item/gun/projectile/revolver/deckard/emp
	ammo_type = /obj/item/ammo_casing/c38/emp

/obj/item/gun/projectile/revolver/deckard/update_icon()
	..()
	if(loaded.len)
		icon_state = "deckard-loaded"
	else
		icon_state = "deckard-empty"

/obj/item/gun/projectile/revolver/deckard/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		flick("deckard-reload",src)
	..()

/obj/item/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	icon_state = "revolver-toy"
	item_state = "revolver"
	caliber = "caps"
	origin_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 1)
	handle_casings = CYCLE_CASINGS
	max_shells = 7
	ammo_type = /obj/item/ammo_casing/cap

/obj/item/gun/projectile/revolver/capgun/attackby(obj/item/wirecutters/W, mob/user)
	if(!istype(W) || icon_state == "revolver")
		return ..()
	to_chat(user, "<span class='notice'>You snip off the toy markings off the [src].</span>")
	name = "revolver"
	icon_state = "revolver"
	desc += " Someone snipped off the barrel's toy mark. How dastardly."
	return 1

/obj/item/gun/projectile/revolver/webley
	name = "service revolver"
	desc = "A rugged top break revolver based on the Webley Mk. VI model, with modern improvements. Uses .44 magnum rounds."
	icon_state = "webley"
	item_state = "webley"
	max_shells = 6
	caliber = ".44"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c44

/obj/item/gun/projectile/revolver/manual/
	name = "Trenchman revolver"
	desc = "The <b>WRC Trenchman</b> is built just as its name suggests for the muck of the trenches.\nIts worn wooden grip feels solid, and the steel frame has a hefty weight to it.\nI mostly remember seeing it holstered on the captain’s hip, though some of the “pracs” carry it too.\nIt’ll just about put down anything in its path. Unlike its jumpy sibling models, the Trenchman’s action is solid, so there’s little chance of it misfiring if bumped. \nThat said, <i>I wouldn’t push my luck.</i>"
	var/primed = FALSE
	var/open = FALSE
	icon = 'icons/obj/gun.dmi'
	icon_state = "manualver"
	safety = FALSE // never.
	can_jam = FALSE
	fire_delay = 0
	burst_delay = 0 // just incase..
	load_delay = 2.5

/obj/item/gun/projectile/revolver/manual/load_ammo(obj/item/A, mob/user)
	if(!open)
		return
	. = ..()

/obj/item/gun/projectile/revolver/manual/unload_ammo(mob/user, allow_dump = TRUE, quickunload = FALSE)
	if(!open)
		return
	. = ..()

/obj/item/gun/projectile/revolver/manual/proc/open(mob/user)
	if(!open)
		open = TRUE
		playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_open.ogg', 85, 1)
		if(primed)
			prime(user)
	update_icon()

/obj/item/gun/projectile/revolver/manual/proc/close(mob/user)
	if(open)
		open = FALSE
		playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_close.ogg', 70, 1)
	update_icon()

/obj/item/gun/projectile/revolver/manual/proc/handle_dryfire(mob/user)
	playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_dryfire.ogg', 50, 1)
	user.show_message(SPAN_DANGER("*Click..*"))

/obj/item/gun/projectile/revolver/manual/MouseDrop(obj/over_object)
	if(!open)
		open(usr)
		return
	//. = ..() // WHY WONT YOU FUCKING UNL OAD D? ? ? ? ? ? ??!!!? WHAT???
		//unload_ammo(usr, allow_dump=TRUE)

/obj/item/gun/projectile/revolver/manual/RightClick(mob/user)
	if(open)
		unload_ammo(usr, allow_dump=TRUE)

/obj/item/gun/projectile/revolver/manual/toggle_safety(mob/user)
	if(open)
		unload_ammo(usr, allow_dump=TRUE)

/obj/item/gun/projectile/revolver/manual/update_icon()
	. = ..()
	if(open)
		icon_state = "[icon_state]_open"
	else
		icon_state = initial(icon_state)

/obj/item/gun/projectile/revolver/manual/proc/prime(mob/user) // unprime to force it
	if(open)
		return // dummy
	var/time = 0.25 SECONDS
	var/fast = FALSE
	switch(user.a_intent)
		if(I_DISARM)
			time=0
			fast=TRUE
		if(I_HURT)
			time=0
			fast=TRUE
	user.doing_something = TRUE
	if(do_after(user, time))
		if(!primed)
			if(fast && ishuman(user))
				var/mob/living/carbon/human/H = user
				if(prob(25) && H.STAT_LEVEL(dex) <= 8) // generous..
					H.flash_weakest_pain()
					H.custom_pain(SPAN_DANGER("MY FINGER- AGH!"),15)
					H.show_message(SPAN_BNOTICE("Your finger gets caught on the hammer.."))
			playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_prime.ogg', 100, 1)
			user.show_message(SPAN_DANGER("You cock the hammer."))
			primed = TRUE
		else
			playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_unprime.ogg', 100, 1)
			user.show_message(SPAN_NOTICE("You uncock the hammer."))
			primed = FALSE
		user.doing_something = FALSE
	else
		user.doing_something = TRUE

/obj/item/gun/projectile/revolver/manual/attack_self(mob/user)
	// for fanning action down the line B)
	if(!open)
		prime(user)
	else
		close(user)

// CHANGING THE /ATTACK CODE DOESNT WORK SO I HAVE TO PUT IT HERE?? WHAT THE FUCK?!!
/obj/item/gun/projectile/revolver/manual/special_check(mob/user)
	if(open)
		// add smth here??
		return FALSE
	else if(!primed)
		handle_dryfire(user)
		return FALSE
	else // jamming, safety etc tho safety wont even happen
		. = ..()

/obj/item/gun/projectile/revolver/manual/Fire(atom/target, mob/living/user, clickparams, pointblank, reflex)
	. = ..()
	primed = FALSE

/obj/item/gun/projectile/revolver/manual/check_gun_safety(mob/user)
	if(!primed || open)
		return FALSE
	. = ..()

//EXECUTION
/obj/item/gun/projectile/revolver/cpt/attack(atom/A, mob/living/user, def_zone)
	if(ishuman(A) && ishuman(user) && A != user)
		var/mob/living/carbon/human/target = A
		var/mob/living/carbon/human/captain = user
		//cap n faction checks
		if(captain.mind?.assigned_role == "Blue Captain" || captain.mind?.assigned_role == "Red Captain")
			if(user.zone_sel.selecting == BP_HEAD && captain.warfare_faction == target.warfare_faction)
				handle_execution(captain, target)
				return

	return ..()

/obj/item/gun/projectile/revolver/cpt/proc/handle_execution(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!ishuman(user) || !ishuman(target))
		return

	var/obj/item/organ/external/head = target.get_organ(BP_HEAD)
	if(!head || head.is_stump())
		to_chat(user, "<span class='warning'>You can't execute someone who doesn't have a head! Where would you even aim?!</span>")
		return

	if(target.stat == DEAD)
		to_chat(user, "<span class='warning'>[target] is already dead! There's no point in shooting a corpse!</span>")
		return

	mouthshoot = 1
	user.visible_message("<span class='danger'>[user] aims their gun at [target]'s head, ready to pull the trigger...</span>")
	playsound(user, 'sound/weapons/guns/fire/execute1.ogg', 75, 0, frequency = 44100)

	if(!do_after(user, 15, target))
		user.visible_message("<span class='notice'>[user] lowers their weapon</span>")
		mouthshoot = 0
		return

	if(safety)
		handle_click_empty(user)
		to_chat(user, "<span class='warning'>You feel rather silly, realizing just now that the safety was on...</span>")
		mouthshoot = 0
		return

	var/obj/item/projectile/in_chamber = consume_next_projectile()
	if(istype(in_chamber))
		user.visible_message("<span class='warning'>[user] pulls the trigger.</span>")
		var/shot_sound = in_chamber.fire_sound ? in_chamber.fire_sound : fire_sound
			playsound(user, shot_sound, 50, 1)
			playsound(user, 'sound/weapons/guns/fire/execute2.ogg', 75, 0, frequency = 44100)

		in_chamber.on_hit(target)
		if(in_chamber.damage_type != PAIN)
			log_and_message_admins("[key_name(user)] executed [key_name(target)] using \a [src]")
			target.apply_damage(in_chamber.damage*2.5, in_chamber.damage_type, BP_HEAD, 0, in_chamber.damage_flags(), used_weapon = "Execution shot to the head with \a [in_chamber]")
			target.death()

			//Apply to nearby soldiers
			var/turf/T = get_turf(user)
			for(var/mob/living/carbon/human/H in range(7, T))
				if(H == user || H == target)
					continue
				if(H.warfare_faction == user.warfare_faction)
					H.add_event("witnessed execution", /datum/happiness_event/witnessed_execution)
		else
			to_chat(target, "<span class='notice'>Ow...</span>")
			target.apply_effect(110, PAIN, 0)

		qdel(in_chamber)
		mouthshoot = 0
		return
	else
		handle_click_empty(user)
		mouthshoot = 0
		return