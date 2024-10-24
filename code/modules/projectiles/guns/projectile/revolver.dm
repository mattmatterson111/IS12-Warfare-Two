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
	unload_sound 	= 'sound/weapons/guns/interact/rev_magout.ogg'
	reload_sound 	= 'sound/weapons/guns/interact/rev_magin.ogg'
	bulletinsert_sound 	= 'sound/weapons/guns/interact/rev_magin.ogg'
	fire_sound = "revolver_fire"
	fire_delay = 0

/obj/item/gun/projectile/revolver/cpt
	name = "Captain's Special"
	desc = "The sort of weapon usually found on nobility, such as captains or commandants."
	icon_state = "cptrevolver"
	item_state = "crevolver"

/obj/item/gun/projectile/revolver/cpt/magistrate
	name = "Commandant's Special"

/obj/item/gun/projectile/revolver/attack_self(mob/user)
	. = ..()
	unload_ammo(user, allow_dump=TRUE)

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
	var/primed = FALSE
	var/open = FALSE

/obj/item/gun/projectile/revolver/manual/load_ammo(obj/item/A, mob/user)
	if(!open)
		return
	. = ..()

/obj/item/gun/projectile/revolver/manual/unload_ammo(obj/item/A, mob/user)
	if(!open)
		return
	. = ..()

/obj/item/gun/projectile/revolver/manual/proc/open(mob/user)
	if(!open)
		open = TRUE
		playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_open.ogg', 85, 1)
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
	. = ..() // WHY WONT YOU FUCKING UNL OAD D? ? ? ? ? ? ??!!!? WHAT???
		//unload_ammo(usr, allow_dump=TRUE)

/obj/item/gun/projectile/revolver/manual/update_icon()
	. = ..()
	/*if(open)
		icon_state = "[icon_state]_open"
	else
		icon_state = initial(icon_state)
*/
/obj/item/gun/projectile/revolver/manual/proc/prime(mob/user, var/fast)
	if(!primed)
		playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_prime.ogg', 100, 1)
		user.show_message(SPAN_DANGER("You cock the hammer."))
		primed = TRUE
	else
		playsound(get_turf(src), 'sound/weapons/guns/interact/revolver_unprime.ogg', 100, 1)
		user.show_message(SPAN_NOTICE("You uncock the hammer."))
		primed = FALSE

/obj/item/gun/projectile/revolver/manual/attack_self(mob/user, var/fast)
	if(!fast) // for fanning action down the line B)
		switch(user.a_intent)
			if(I_DISARM) fast = TRUE
			else if(I_HURT) fast = TRUE
			else fast = FALSE
	if(!open)
		prime(user, fast)
	else
		close(user)

// CHANGING THE /ATTACK CODE DOESNT WORK SO I HAVE TO PUT IT HERE?? WHAT THE FUCK?!!
/obj/item/gun/projectile/revolver/manual/Fire(atom/target, mob/living/user, clickparams, pointblank, reflex)
	if(!primed)
		handle_dryfire(user)
		return
	else
		. = ..()
		primed = FALSE