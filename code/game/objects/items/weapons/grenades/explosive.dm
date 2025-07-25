/obj/item/projectile/bullet/pellet/fragment
	damage = 100
	range_step = 2 //controls damage falloff with distance. projectiles lose a "pellet" each time they travel this distance. Can be a non-integer.

	base_spread = 0 //causes it to be treated as a shrapnel explosion instead of cone
	spread_step = 20

	silenced = 1
	fire_sound = null
	no_attack_log = 1
	muzzle_type = null
	do_not_pass_trench = TRUE

/obj/item/projectile/bullet/pellet/fragment/strong
	damage = 40

/obj/item/grenade/frag
	name = "fragmentation grenade"
	desc = "A military fragmentation grenade, designed to explode in a deadly shower of fragments, while avoiding massive structural damage."
	icon_state = "frggrenade"
	arm_sound = 'sound/weapons/grenade_arm.ogg'
	throw_range = 10
	icon = 'icons/obj/grenade.dmi'

	var/list/fragment_types = list(/obj/item/projectile/bullet/pellet/fragment = 1)
	var/num_fragments = 72  //total number of fragments produced by the grenade
	var/explosion_size = 2   //size of the center explosion

	//The radius of the circle used to launch projectiles. Lower values mean less projectiles are used but if set too low gaps may appear in the spread pattern
	var/spread_range = 7 //leave as is, for some reason setting this higher makes the spread pattern have gaps close to the epicenter

/obj/item/grenade/frag/attack_self(mob/user as mob)
	if(aspect_chosen(/datum/aspect/trenchmas))
		return
	if(aspect_chosen(/datum/aspect/no_guns))//No grenades in slappers only please.
		to_chat(user, "The pin seems stuck, it won't go off.")
		return
	..()

/obj/item/grenade/frag/detonate()
	..()

	var/turf/O = get_turf(src)
	if(!O) return

	if(explosion_size)
		on_explosion(O)

	src.fragmentate(O, num_fragments, spread_range, fragment_types)
	qdel(src)


/atom/proc/fragmentate(var/turf/T=get_turf(src), var/fragment_number = 30, var/spreading_range = 5, var/list/fragtypes=list(/obj/item/projectile/bullet/pellet/fragment/))
	set waitfor = 0
	var/list/target_turfs = getcircle(T, spreading_range)
	var/fragments_per_projectile = round(fragment_number/target_turfs.len)

	playsound(src, 'sound/weapons/grenade_exp.ogg')
	for(var/turf/O in target_turfs)
		sleep(0)
		var/fragment_type = pickweight(fragtypes)
		var/obj/item/projectile/bullet/pellet/fragment/P = new fragment_type(T)
		P.pellets = fragments_per_projectile
		P.shot_from = src.name

		P.launch_projectile(O)

		//Make sure to hit any mobs in the source turf
		for(var/mob/living/M in T)
			//lying on a frag grenade while the grenade is on the ground causes you to absorb most of the shrapnel.
			//you will most likely be dead, but others nearby will be spared the fragments that hit you instead.
			if(M.lying && isturf(src.loc))
				P.attack_mob(M, 0, 5)
			else if(!M.lying && src.loc != get_turf(src)) //if it's not on the turf, it must be in the mob!
				P.attack_mob(M, 0, 25) //you're holding a grenade, dude!
			else
				P.attack_mob(M, 0, 100) //otherwise, allow a decent amount of fragments to pass

/obj/item/grenade/fire
	name = "incendiary grenade"
	desc = "A military incendiary grenade designed to spread and ignite a vast ammount of highly flammable liquid."
	icon_state = "fire_grenade"
	arm_sound = 'sound/weapons/grenade_arm.ogg'
	throw_range = 10

	var/fire_range = 2 // size of the fire zone

/obj/item/grenade/fire/detonate()
	..()

	var/turf/O = get_turf(src)
	if(!O) return

	new /obj/flamer_fire(loc, 8, 6, "red", fire_range)

	qdel(src)

/obj/mortar/frag
	name = "Mortar"
	desc = "You'll never see this it just explodes."

/obj/mortar/frag/New()
	..()
	fragmentate(get_turf(src), 72)
	qdel(src)

/obj/mortar/gas
	name = "gas mortar"

/obj/mortar/gas/New()
	..()
	create_reagents(100)
	reagents.add_reagent(/datum/reagent/toxin/mustard_gas, 50)
	var/location = get_turf(src)
	var/datum/effect/effect/system/smoke_spread/chem/S = new()
	S.particles = FALSE
	S.attach(location)
	S.set_up(reagents, 50, 0, location)
	spawn(0)
		S.start()
	qdel(src)

/obj/mortar/fire
	name = "fire mortar"

/obj/mortar/fire/New()//Just spawns fire.
	..()
	new /obj/flamer_fire(loc, 12, 10, "red", 8)
	qdel(src)

/obj/mortar/flare
	name = "illumination mortar"
	var/flare_type = /obj/effect/lighting_dummy/flare

obj/mortar/flare/blue
	flare_type = /obj/effect/lighting_dummy/flare/blue

/obj/mortar/flare/New()//Just spawns a flare.
	..()
	new flare_type(loc)
	qdel(src)

/obj/item/grenade/frag/proc/on_explosion(var/turf/O)
	if(explosion_size)
		explosion(O, -1, -1, explosion_size, round(explosion_size/2), 0, particles = TRUE, large = FALSE, color = COLOR_BLACK, autosize = FALSE, sizeofboom = 1, explosionsound = pick('sound/effects/mortarexplo1.ogg','sound/effects/mortarexplo2.ogg','sound/effects/mortarexplo3.ogg'), farexplosionsound = pick('sound/effects/farexplonewnew1.ogg','sound/effects/farexplonewnew2.ogg','sound/effects/farexplonewnew3.ogg'))

/obj/item/grenade/frag/warfare
	desc = "Throw it at THE ENEMEY!"
	icon_state = "warfare_grenade"
	arm_sound = "arm"

/obj/item/grenade/frag/warfare/activate(mob/user)
	. = ..()
	layer = BASE_ABOVE_OBJ_LAYER+1 // just so it showsu p above dirt barricades

/obj/item/grenade/frag/ex_act(severity)
	. = ..()
	if(severity)
		detonate()


/obj/item/grenade/frag/shell
	name = "fragmentation grenade"
	desc = "A light fragmentation grenade, designed to be fired from a launcher. It can still be activated and thrown by hand if necessary."
	icon_state = "fragshell"

	num_fragments = 50 //less powerful than a regular frag grenade


/obj/item/grenade/frag/high_yield
	name = "fragmentation bomb"
	desc = "Larger and heavier than a standard fragmentation grenade, this device is extremely dangerous. It cannot be thrown as far because of its weight."
	icon_state = "frag"

	w_class = ITEM_SIZE_NORMAL
	throw_speed = 3
	throw_range = 5 //heavy, can't be thrown as far

	fragment_types = list(/obj/item/projectile/bullet/pellet/fragment=1,/obj/item/projectile/bullet/pellet/fragment/strong=4)
	num_fragments = 200  //total number of fragments produced by the grenade
	explosion_size = 3

/obj/item/grenade/frag/high_yield/on_explosion(var/turf/O)
	if(explosion_size)
		explosion(O, -1, round(explosion_size/2), explosion_size, round(explosion_size/2), 0, particles = TRUE, autosize = TRUE, color = COLOR_BLACK) //has a chance to blow a hole in the floor
