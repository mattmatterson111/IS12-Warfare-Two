#define MUZZLE_EFFECT_PIXEL_INCREMENT 16	//How many pixels to move the muzzle flash up so your character doesn't look like they're shitting out lasers.

#define DEBRIS_SPARKS "spark"
#define DEBRIS_WOOD "wood"
#define DEBRIS_ROCK "rock"
#define DEBRIS_GLASS "glass"
#define DEBRIS_LEAF "leaf"
#define DEBRIS_SNOW "snow"

///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = 0
	appearance_flags = KEEP_APART|TILE_BOUND
	plane = EFFECTS_BELOW_LIGHTING_PLANE
	layer = 100

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = null)
	. = ..()
	if(!loc)
		message_admins("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	particles = new particle_path

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	return ..()


/particles/debris
	icon = 'icons/effects/particles/generic_particles.dmi'
	width = 500
	height = 500
	count = 10
	spawning = 10
	lifespan = 0.7 SECONDS
	fade = 0.4 SECONDS
	drift = generator(GEN_CIRCLE, 0, 7)
	scale = 0.7
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.15)
	spin = generator(GEN_NUM, -20, 20)

/particles/impact_smoke
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 500
	height = 500
	count = 20
	spawning = 20
	lifespan = 0.7 SECONDS
	fade = 8 SECONDS
	grow = 0.1
	scale = 0.2
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.1, 0.5)

/particles/firing_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoke5"
	//icon_state = "smallsmoke"
	//icon = 'icons/effects/effects.dmi'
	width = 500
	height = 500
	count = 5
	spawning = 15
	lifespan = 0.5 SECONDS
	fade = 2.4 SECONDS
	grow = 0.12
	drift = generator(GEN_CIRCLE, 8, 8)
	scale = 0.1
	spin = generator(GEN_NUM, -20, 20)
	velocity = list(50, 0)
	friction = generator(GEN_NUM, 0.3, 0.6)


/atom/proc/visual_effect(var/obj/item/projectile/P)
	var/debris = DEBRIS_SPARKS
	var/debris_velocity = -15
	var/debris_amount = 8
	var/debris_scale = 0.7
	var/x_component = sin(P.Angle) * debris_velocity
	var/y_component = cos(P.Angle) * debris_velocity
	var/x_component_smoke = sin(P.Angle) * -15
	var/y_component_smoke = cos(P.Angle) * -15
	var/obj/effect/abstract/particle_holder/debris_visuals
	var/obj/effect/abstract/particle_holder/smoke_visuals
	var/position_offset = rand(-6,6)
	smoke_visuals = new(src, /particles/impact_smoke)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)
	smoke_visuals.plane = ABOVE_HUMAN_PLANE

	debris_visuals = new(src, /particles/debris)
	debris_visuals.particles.position = generator(GEN_CIRCLE, position_offset, position_offset)
	debris_visuals.particles.velocity = list(x_component, y_component)
	debris_visuals.layer = ABOVE_OBJ_LAYER + 0.02
	debris_visuals.plane = ABOVE_HUMAN_PLANE
	debris_visuals.particles.icon_state = debris
	debris_visuals.particles.count = debris_amount
	debris_visuals.particles.spawning = debris_amount
	debris_visuals.particles.scale = debris_scale
	smoke_visuals.layer = ABOVE_OBJ_LAYER + 0.01
	addtimer(CALLBACK(src, PROC_REF(remove_ping), smoke_visuals, debris_visuals), 0.7 SECONDS)

/atom/proc/remove_ping(obj/effect/abstract/particle_holder/smoke_visuals, obj/effect/abstract/particle_holder/debris_visuals)
	QDEL_NULL(smoke_visuals)
	if(debris_visuals)
		QDEL_NULL(debris_visuals)


/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = TRUE
	unacidable = TRUE
	anchored = TRUE				//There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	pass_flags = PASS_FLAG_TABLE
	mouse_opacity = 0
	animate_movement = 0	//Use SLIDE_STEPS in conjunction with legacy
	randpixel = 0
	var/projectile_type = /obj/item/projectile

	var/list/mob_hit_sound = list('sound/effects/gore/bullethit1.ogg', 'sound/effects/gore/bullethit2.ogg', 'sound/effects/gore/bullethit3.ogg', 'sound/effects/gore/bullethit4.ogg') //Sound it makes when it hits a mob. It's a list so you can put multiple hit sounds there.
	var/wall_hitsound = "hitwall"
	var/list/armor_hit_sound = list('sound/effects/gore/armorhit1.ogg', 'sound/effects/gore/armorhit2.ogg','sound/effects/gore/armorhit3.ogg','sound/effects/gore/armorhit4.ogg')
	var/list/helmet_hit_sound = list('sound/effects/gore/helmhit1.ogg', 'sound/effects/gore/helmhit2.ogg','sound/effects/gore/helmhit3.ogg','sound/effects/gore/helmhit4.ogg','sound/effects/gore/helmhit5.ogg')
	var/fire_sound = 'sound/weapons/gunshot/gunshot.ogg'//Default gun sound.
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = FALSE	//Attack message
	var/bumped

	var/shot_from = "" // name of the object which shot us

	var/accuracy = 0
	var/dispersion = 0.0

	//used for shooting at blank range, you shouldn't be able to miss
	var/can_miss = 0

	var/taser_effect = 0 //If set then the projectile will apply it's agony damage using stun_effect_act() to mobs it hits, and other damage will be ignored

	//Effects
	var/damage = 10
	var/damage_type = BRUTE		//BRUTE, BURN, TOX, OXY, CLONE, HALLOSS are the only things that should be in here
	var/nodamage = FALSE		//Determines if the projectile will skip any damage inflictions
	var/check_armour = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb	//Cael - bio and rad are also valid

	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/agony = 0

	var/incinerate = 0
	var/embed = 0 // whether or not the projectile can embed itself in the mob
	var/shrapnel_type //type of shrapnel the projectile leaves in its target.

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	//For Maim / Maiming.
	var/maiming = 0 //Enables special limb dismemberment calculation; used primarily for ranged weapons that can maim, but do not do brute damage.
	var/maim_rate = 0 //Factor that the recipiant will be maimed by the projectile (NOT OUT OF 100%.)
	var/clean_cut = 0 //Is the delimbning painful and unclean? Probably. Can be a function or proc, if you're doing something odd.
	var/maim_type = DROPLIMB_EDGE
	/*Does the projectile simply lop/tear the limb off, or does it vaporize it?
	Set maim_type to DROPLIMB_EDGE to chop off the limb
	set maim_type to DROPLIMB_BURN to vaporize it.
	set maim_type to DROPLIMB_BLUNT to gib (Explode/Hamburger) the limb.
	*/

	//Movement parameters
	var/speed = 0.2			//Amount of deciseconds it takes for projectile to travel
	var/pixel_speed = 33	//pixels per move - DO NOT FUCK WITH THIS UNLESS YOU ABSOLUTELY KNOW WHAT YOU ARE DOING OR UNEXPECTED THINGS /WILL/ HAPPEN!
	var/Angle = 0
	var/original_angle = 0		//Angle at firing
	var/nondirectional_sprite = FALSE //Set TRUE to prevent projectiles from having their sprites rotated based on firing angle
	var/yo = null
	var/xo = null
	var/atom/original			// the target clicked (not necessarily where the projectile is headed). Should probably be renamed to 'target' or something.
	var/turf/starting			// the projectile's starting turf
	var/list/permutated			// we've passed through these atoms, don't try to hit them again
	var/penetrating = 0			//If greater than zero, the projectile will pass through dense objects as specified by on_penetrate()
	var/penetration_modifier = 0.2 //How much internal damage this projectile can deal, as a multiplier.
	var/forcedodge = FALSE		//to pass through everything
	var/ignore_source_check = FALSE

	//Fired processing vars
	var/fired = FALSE	//Have we been fired yet
	var/paused = FALSE	//for suspending the projectile midair
	var/last_projectile_move = 0
	var/last_process = 0
	var/time_offset = 0
	var/datum/point/vector/trajectory
	var/trajectory_ignore_forcemove = FALSE	//instructs forceMove to NOT reset our trajectory to the new location!
	var/range = 50 //This will de-increment every step. When 0, it will deletze the projectile.
	var/aoe = 0 //For KAs, really

	//Hitscan
	var/hitscan = FALSE		//Whether this is hitscan. If it is, speed is basically ignored.
	var/list/beam_segments	//assoc list of datum/point or datum/point/vector, start = end. Used for hitscan effect generation.
	var/datum/point/beam_index
	var/turf/hitscan_last	//last turf touched during hitscanning.
	var/tracer_type
	var/muzzle_type
	var/impact_type
	var/hit_effect
	var/matrix/effect_transform			// matrix to rotate and scale projectile effects - putting it here so it doesn't
										//  have to be recreated multiple times
	var/non_trench_counter = 0 //For trench cover bullshit.
	var/trench_counter = 0
	var/do_not_pass_trench = FALSE //For stuff you do not want to leave the trench.
	var/cover_checked = FALSE
	var/increments = 0

/obj/item/projectile/CanPass()
	return TRUE

//TODO: make it so this is called more reliably, instead of sometimes by bullet_act() and sometimes not
/obj/item/projectile/proc/on_hit(var/atom/target, var/blocked = 0, var/def_zone = null)
	set waitfor = 0
	if(blocked >= 100)	//Full block
		return FALSE
	if(!isliving(target))
		return FALSE
	if(isanimal(target))
		return FALSE
	var/mob/living/L = target
	if(damage && damage_type == BRUTE)
		var/turf/target_loca = get_turf(target)
		var/splatter_dir = dir
		if(starting)
			splatter_dir = get_dir(starting, target_loca)
			target_loca = get_step(target_loca, splatter_dir)
		if(isalien(L))
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter/xenosplatter(get_turf(target), splatter_dir)
		else
			var/blood_color = "#C80000"
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				blood_color = H.species.blood_color
			new /obj/effect/overlay/temp/dir_setting/bloodsplatter(get_turf(target), splatter_dir, blood_color)
		//if(prob(50))
		var/obj/effect/decal/cleanable/blood/B = blood_splatter(target_loca, L, 1, splatter_dir)
		B.icon_state = pick("dir_splatter_1","dir_splatter_2")
		var/scale = min(1, round(damage / 50, 0.2))
		var/matrix/M = new()
		B.transform = M.Scale(scale)
			//target_loca.add_blood(L)

	L.apply_effects(stun, weaken, paralyze, 0, stutter, eyeblur, drowsy, agony, incinerate, blocked)
	L.apply_effect(irradiate, IRRADIATE, L.getarmor(null, "rad")) //radiation protection is handled separately from other armour types.
	return 1

//called when the projectile stops flying because it collided with something
/obj/item/projectile/proc/on_impact(var/atom/A)
	set waitfor = 0
	if(ismob(A))
		return
	var/turf/T = get_turf(A)
	if(T)
		T.visual_effect(src)

//Checks if the projectile is eligible for embedding. Not that it necessarily will.
/obj/item/projectile/proc/can_embed()
	//embed must be enabled and damage type must be brute
	if(!embed || damage_type != BRUTE)
		return FALSE
	return TRUE

/obj/item/projectile/proc/get_structure_damage()
	if(damage_type == BRUTE || damage_type == BURN)
		return damage
	return FALSE

//return TRUE if the projectile should be allowed to pass through after all, FALSE if not.
/obj/item/projectile/proc/check_penetrate(atom/A)
	return TRUE

/obj/item/projectile/proc/launch_projectile(atom/target, target_zone, mob/user, params, angle_override, forced_spread = 0)
	original = target
	def_zone = check_zone(target_zone)
	firer = user
	var/direct_target
	if(get_turf(target) == get_turf(src))
		direct_target = target

	preparePixelProjectile(target, user? user : get_turf(src), params, forced_spread)
	return fire(angle_override, direct_target)

//called to launch a projectile from a gun
/obj/item/projectile/proc/launch_from_gun(atom/target, target_zone, mob/user, params, angle_override, forced_spread, var/obj/item/gun/launcher)

	shot_from = launcher.name
	silenced = launcher.silenced

	if(launcher.damage_modifier)
		damage *= launcher.damage_modifier

	return launch_projectile(target, target_zone, user, params, angle_override, forced_spread)


/obj/item/projectile/proc/istargetloc(mob/living/target_mob)
	if(target_mob && original)
		var/turf/originalloc
		if(!istype(original, /turf))
			originalloc = original.loc
		else
			originalloc = original
		if(originalloc == target_mob.loc)
			return 1
		else
			return 0
	else
		return 0

//Called when the projectile intercepts a mob. Returns 1 if the projectile hit the mob, 0 if it missed and should keep flying.
/obj/item/projectile/proc/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier=0)
	if(!istype(target_mob))
		return

	//roll to-hit
	//miss_modifier = max(15*(distance-1) - round(25*accuracy) + miss_modifier, 0)
	miss_modifier = 15*(distance-2) - round(15*accuracy) + miss_modifier
	if(target_mob == src.original)
		miss_modifier -= 60
	var/hit_zone = get_zone_with_miss_chance(def_zone, target_mob, miss_modifier, ranged_attack=(distance > 1 || original != target_mob)) //if the projectile hits a target we weren't originally aiming at then retain the chance to miss

	var/result = PROJECTILE_FORCE_MISS
	var/do_normal_check = TRUE
	if(hit_zone)
		def_zone = hit_zone //set def_zone, so if the projectile ends up hitting someone else later (to be implemented), it is more likely to hit the same part
		if(def_zone)
			switch(target_mob.dir)
				if(2)
					if(p_y <= 10) //legs level
						if(p_x  >= 17)
							if(def_zone == BP_L_LEG || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_L_ARM \
							|| def_zone == BP_CHEST)
								def_zone = BP_L_LEG
							if(def_zone == BP_HEAD || def_zone == BP_R_ARM)
								def_zone = BP_CHEST
							//lleg
						else
							if(def_zone == BP_L_LEG || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST)
								def_zone = BP_R_LEG
							if(def_zone == BP_HEAD || def_zone == BP_L_ARM)
								def_zone = BP_CHEST
							//rleg
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_L_LEG, BP_R_LEG)

					if(p_y > 10 && p_y <= 13) //groin level
						if(p_x <= 12)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							if(def_zone == BP_HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							//rarm
						if(p_x > 12 && p_x < 21)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG)
								def_zone = BP_GROIN
							if(def_zone == BP_HEAD)
								def_zone = BP_CHEST
							//groin
						if(p_x >= 21 && p_x < 24)
							//larm
							if(def_zone == BP_L_ARM || def_zone == BP_L_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_L_ARM
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST

						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_GROIN)

					if(p_y > 13 && p_y <= 22)
						if(p_x <= 12)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							if(def_zone == BP_HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							//rarm
						if(p_x > 12 && p_x < 21)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG \
							|| def_zone == BP_HEAD)
								def_zone = BP_CHEST
							//chest

						if(p_x >= 21 && p_x < 24)
							if(def_zone == BP_L_ARM || def_zone == BP_HEAD\
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG)
								def_zone = BP_L_ARM
							//larm
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST

						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST)

					if(p_y > 22 && p_y <= 32)
						if(def_zone == BP_L_ARM \
						|| def_zone == BP_R_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_HEAD
						//head
						if(def_zone == BP_GROIN || def_zone == BP_R_LEG || \
						def_zone == BP_L_LEG)
							def_zone = BP_CHEST

						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_HEAD, BP_CHEST)
				if(1)
					if(p_y <= 10) //legs level
						if(p_x  >= 17)
							if(def_zone == BP_L_LEG || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST)
								def_zone = BP_R_LEG
							if(def_zone == BP_HEAD || def_zone == BP_L_ARM)
								def_zone = BP_CHEST
							//rleg

						else
							if(def_zone == BP_L_LEG || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_L_ARM \
							|| def_zone == BP_CHEST)
								def_zone = BP_L_LEG
							if(def_zone == BP_HEAD || def_zone == BP_L_ARM)
								def_zone = BP_CHEST
							//lleg
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_LEG, BP_L_LEG, BP_CHEST)

					if(p_y > 10 && p_y <= 13) //groin level
						if(p_x <= 12)
							if(def_zone == BP_L_ARM || def_zone == BP_L_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_L_ARM
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST
							//larm
						if(p_x > 12 && p_x < 21)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG)
								def_zone = BP_GROIN
							if(def_zone == BP_HEAD)
								def_zone = BP_CHEST
							//groin
						if(p_x >= 21 && p_x < 24)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							if(def_zone == BP_HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							//rarm
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_GROIN)
					if(p_y > 13 && p_y <= 22)
						if(p_x <= 12)
							if(def_zone == BP_L_ARM || def_zone == BP_L_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_L_ARM
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST
							//larm
						if(p_x > 12 && p_x < 21)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG \
							|| def_zone == BP_HEAD)
								def_zone = BP_CHEST
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST
							//chest
						if(p_x >= 21 && p_x < 24)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							if(def_zone == BP_HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							//rarm
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST)

					if(p_y > 22 && p_y <= 32)
						if(def_zone == BP_L_ARM \
						|| def_zone == BP_R_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_HEAD
						if(def_zone == BP_GROIN || def_zone == BP_L_LEG || \
						def_zone == BP_R_LEG)
							def_zone = BP_CHEST
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_HEAD)
						//head
				if(4)
					if(p_y <= 10) //legs level
						if(def_zone == BP_R_LEG \
						|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_R_LEG
						if(def_zone == BP_HEAD || def_zone == BP_R_ARM)
							def_zone = BP_CHEST
						if(def_zone == BP_L_LEG)
							def_zone = BP_L_LEG
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_LEG, BP_L_LEG, BP_CHEST)
						//rleg

					if(p_y > 10 && p_y <= 13) //groin level
						if(p_x < 16)
							if(def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							if(def_zone == HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							if(def_zone == BP_L_ARM)
								def_zone = BP_L_ARM
							//rarm
						if(p_x >= 16)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG)
								def_zone = BP_GROIN
							if(def_zone == BP_HEAD)
								def_zone = BP_CHEST

						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_GROIN)
							//groin

					if(p_y > 13 && p_y <= 22)
						if(p_x >= 16)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG \
							|| def_zone == HEAD)
								def_zone = BP_CHEST
							//chest
						if(p_x < 16)
							if(def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_R_ARM
							//rarm
							if(def_zone == BP_HEAD || def_zone == BP_L_LEG)
								def_zone = BP_CHEST
							if(def_zone == BP_L_ARM)
								def_zone = BP_L_ARM
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST)

					if(p_y > 22 && p_y <= 32)
						if(def_zone == BP_L_ARM \
						|| def_zone == BP_R_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_HEAD
						if(def_zone ==  BP_GROIN || def_zone == BP_L_LEG || def_zone == BP_R_LEG)
							def_zone = BP_CHEST
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_HEAD)
						//head

				if(8)
					if(p_y <= 10) //legs level
						//lleg
						if(def_zone == BP_L_LEG \
						|| def_zone == BP_GROIN || def_zone == BP_L_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_L_LEG

						if(def_zone == BP_HEAD || def_zone == BP_R_ARM)
							def_zone = BP_CHEST

						if(def_zone == BP_R_LEG)
							def_zone = BP_R_LEG
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_LEG, BP_L_LEG, BP_CHEST)

					if(p_y > 10 && p_y <= 13) //groin level
						if(p_x < 16)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG)
								def_zone = BP_GROIN
							if(def_zone == BP_HEAD)
								def_zone = BP_CHEST
							//groin
						if(p_x >= 16)
							if(def_zone == BP_L_ARM || def_zone == BP_L_LEG \
							|| def_zone == BP_GROIN \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_L_ARM
							if(def_zone == BP_HEAD || def_zone == BP_R_LEG)
								def_zone = BP_CHEST
							if(def_zone == BP_R_ARM)
								def_zone = BP_R_ARM
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_GROIN)
							//left_arm

					if(p_y > 13 && p_y <= 22)
						if(p_x < 16)
							if(def_zone == BP_L_ARM || def_zone == BP_R_LEG \
							|| def_zone == BP_GROIN || def_zone == BP_R_ARM \
							|| def_zone == BP_CHEST || def_zone == BP_L_LEG \
							|| def_zone == BP_HEAD)
								def_zone = BP_CHEST
							//chest
						if(p_x >= 16)
							if(def_zone == BP_L_ARM || def_zone == BP_L_LEG \
							|| def_zone == BP_GROIN \
							|| def_zone == BP_CHEST || def_zone == BP_HEAD)
								def_zone = BP_L_ARM
							if(def_zone == BP_R_LEG || def_zone == BP_HEAD)
								def_zone = BP_CHEST
							if(def_zone == BP_R_ARM)
								def_zone = BP_R_ARM
							//larm
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST)

					if(p_y > 22 && p_y <= 32)
						if(def_zone == BP_L_ARM \
						|| def_zone == BP_R_ARM \
						|| def_zone == BP_CHEST)
							def_zone = BP_HEAD
						if(def_zone ==  BP_GROIN || def_zone == BP_L_LEG || def_zone == BP_R_LEG)
							def_zone = BP_CHEST
						if(istargetloc(target_mob) == 0)
							def_zone = pick(BP_R_ARM, BP_L_ARM, BP_CHEST, BP_HEAD)
						//head

			if(firer)
				if(istype(firer.loc, /turf/simulated/floor/trench))
					if(firer.lying)
						do_normal_check = FALSE
						result = PROJECTILE_FORCE_MISS
						to_chat(firer, "I'm lying down I can't hit shit.")

			if(ishuman(firer) && ishuman(target_mob)) //I will let Kas suffer. I think he should know why this was put in here.
				var/mob/living/carbon/human/attacker = firer //I will no longer suffer. I see the future and the past now. Thank you.
				var/mob/living/carbon/human/victim = target_mob
				if(!attacker.HasRoleSimpleCheck("Blue Captain") || !attacker.HasRoleSimpleCheck("Red Captain"))
					if(attacker != victim && victim.stat != DEAD) // TWOFARE EDIT -- Enable friendly fire again :)
						if(attacker?.warfare_faction == victim?.warfare_faction)
							do_normal_check = FALSE
							result = PROJECTILE_FORCE_MISS

			if(cover_checked)//We passed over cover at some point.
				if(target_mob.crouching || target_mob.lying)//The person is lying down so don't hit them.
					do_normal_check = FALSE
					result = PROJECTILE_FORCE_MISS

			if(istype(target_mob.loc, /turf/simulated/floor/trench))//Shooting at someone in a trench.
				if(non_trench_counter > 1)//Bullet was shot from open terrain.
					var/mob/living/carbon/human/victim = target_mob
					var/msg = pick("THEY'RE TRYING TO KILL ME!",
							"THAT WAS CLOSE!",
							"THEY'RE SHOOTING AT ME!",
							"TOO CLOSE!",
							"FUCK, FUCK!")
					if(original != target_mob)//We weren't shooting at them, so whizz past.
						do_normal_check = FALSE
						result = PROJECTILE_FORCE_MISS
						to_chat(target_mob, "<span class='danger'>BULLETS WHIZZ PAST MY HEAD!</span>")
						if(prob(victim.STAT_LEVEL(end))) //getting shot at probably gives people adrenaline
							to_chat(target_mob, "<span class='phobia'>[msg]</span>")
							victim.make_adrenaline(damage/20)
						shake_camera(target_mob, 3, 2)//More supression effects.
						target_mob.recoil += 15 //Make them innacurate for a tick when being supressed.

					else//We were actually shooting at them.
						if(target_mob.lying || target_mob.crouching)//If the target is lying or crouching the bullets whizz right past them.
							do_normal_check = FALSE
							result = PROJECTILE_FORCE_MISS
							to_chat(target_mob, "<span class='danger'>BULLETS WHIZZ PAST MY HEAD!</span>")
							if(prob(victim.STAT_LEVEL(end))) //getting shot at probably gives people adrenaline
								to_chat(target_mob, "<span class='phobia'>[msg]</span>")
								victim.make_adrenaline(damage/20)
							shake_camera(target_mob, 3, 2)//More supression effects.
							target_mob.recoil += 15 //Make them innacurate for a tick when being supressed.
						else if(prob(rand(1,15)))//Chance to miss, minmum of 1, max of 15.
							do_normal_check = FALSE
							result = PROJECTILE_FORCE_MISS

			else if(!istype(target_mob.loc, /turf/simulated/floor/trench))//They're not in a trench.
				if(istype(starting, /turf/simulated/floor/trench))//We are in a trench.
					if(firer && firer.lying) //We are lying down.
						do_normal_check = FALSE
						result = PROJECTILE_FORCE_MISS //We cannot hit them. Because being able to lie down and shoot them is fucking stupid.
						to_chat(firer, "<span class='warning'>I cannot hit them lying down like this.</span>")

			if(do_normal_check)
				result = target_mob.bullet_act(src, def_zone)//this returns mob's armor_check and another - see modules/mob/living/living_defense.dm

	if(result == PROJECTILE_FORCE_MISS)
		if(!silenced)
			var/missound = "sound/weapons/guns/misc/miss[rand(1,4)].ogg"
			playsound(target_mob, missound, 60, 1)
			target_mob.overlay_fullscreen("supress",/obj/screen/fullscreen/oxy, 5)
			shake_camera(target_mob, 3, 2)//More supression effects.
			target_mob.recoil += 15 //Make them innacurate for a tick when being supressed.
			spawn(5)
				target_mob.clear_fullscreen("supress", 5)
		return 0

	if(ishuman(target_mob))
		var/mob/living/carbon/human/L = target_mob
		if(istype(L.wear_suit, /obj/item/clothing/suit/armor) && parse_zone(def_zone) == BP_CHEST)
			playsound(L,pick(armor_hit_sound), 100, 1)
		if(istype(L.head, /obj/item/clothing/head/helmet) && parse_zone(def_zone) == BP_HEAD)
			var/obj/item/clothing/head/helmet/helm = L.head
			helm.take_damage(damage)
			playsound(L, pick(helmet_hit_sound), 80, 1)
		if(ishuman(firer))//Stuff that isn't a mob doesn't play well with achievements.
			if(parse_zone(def_zone) == BP_HEAD)//Boom headshot bitch.
				firer.unlock_achievement(new/datum/achievement/headshot())

	playsound(target_mob, safepick(mob_hit_sound), 85, 1)
	//admin logs
	if(!no_attack_log)
		if(istype(firer, /mob))

			var/attacker_message = "shot with \a [src.type]"
			var/victim_message = "shot with \a [src.type]"
			var/admin_message = "shot (\a [src.type])"

			admin_attack_log(firer, target_mob, attacker_message, victim_message, admin_message)
		else
			admin_victim_log(target_mob, "was shot by an <b>UNKNOWN SUBJECT (No longer exists)</b> using \a [src]")

	if(ishuman(firer) && ishuman(target_mob))
		var/mob/living/carbon/human/attacker = firer
		var/mob/living/carbon/human/victim = target_mob
		if(attacker != victim && victim.stat != DEAD)
			if(attacker.warfare_faction)
				if(attacker.warfare_faction == victim.warfare_faction && victim.stat != DEAD)
					to_chat(attacker, "<big>[victim] is on my side!</big>")
					log_and_message_admins("[attacker] has shot his teammate [victim] with \a [src.type]!", attacker)
					GLOB.ff_incidents++//Dumb round end stat stuff.


	//sometimes bullet_act() will want the projectile to continue flying
	if (result == PROJECTILE_CONTINUE)
		return FALSE

	return TRUE

/obj/item/projectile/Bump(atom/A as mob|obj|turf|area, forced=0)
	set waitfor = 0
	. = ..()
	if(A == src)
		return FALSE	//no.

	if((bumped && !forced) || (A in permutated))
		return FALSE

	if(firer && !ignore_source_check)
		if(A == firer || (A == firer.loc)) //cannot shoot yourself or your mech
			trajectory_ignore_forcemove = TRUE
			forceMove(get_turf(A))
			trajectory_ignore_forcemove = FALSE
			return FALSE


	var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
	var/passthrough = FALSE //if the projectile should continue flying
	bumped = 1
	if(ismob(A))
		var/mob/M = A
		if(istype(A, /mob/living))
			//if they have a grab on someone, that person gets hit instead
			var/obj/item/grab/G = locate() in M
			var/mob/living/carbon/human/stoplying = A //balancing
			var/bad_arc = reverse_direction(A.dir) //getting shot from behind means no human shielding
			if(G && G.shield_assailant() && !stoplying.lying && check_shield_arc(A, bad_arc, src))
				var/turf/moveto = get_step(M, get_dir(M, starting)) //get direction of projectile
				var/actuallymoveshield = TRUE
				A.set_dir(get_dir(M, starting))
				for(var/obj/structure/object in moveto.contents)  
					if(istype(object, /obj/structure/anti_tank)) //dont move em into an impassible object because of a PTSD round please thanks
						actuallymoveshield = FALSE
						break //found one, stop looking
				if(actuallymoveshield)
					G.affecting.forceMove(moveto) //move em in the way
				stoplying.adjustStaminaLoss(damage) //balancing
				G.force_them_up() 
				G.affecting.update_canmove() //stand em up
				visible_message("<span class='danger'>\The [M] uses [G.affecting] as a shield!</span>")
				if(Bump(G.affecting))
					G.get_back_down() //and set em back down afterwards.
					return //If Collide() returns 0 (keep going) then we continue on to attack M.
				G.get_back_down() //just to be sure

			passthrough = !attack_mob(M, distance)
		else
			passthrough = TRUE	//so ghosts don't stop bullets
	else
		playsound(loc, wall_hitsound, 50)
		passthrough = (A.bullet_act(src, def_zone) == PROJECTILE_CONTINUE) //backwards compatibility
		if(isturf(A))
			for(var/obj/O in A)
				O.bullet_act(src)
			for(var/mob/living/M in A)
				attack_mob(M, distance)

	//penetrating projectiles can pass through things that otherwise would not let them
	if(!passthrough && penetrating > 0)
		if(check_penetrate(A))
			passthrough = TRUE
		penetrating--

	//the bullet passes through a dense object!
	if(passthrough || forcedodge)
		//move ourselves onto A so we can continue on our way.
		if(A)
			trajectory_ignore_forcemove = TRUE
			if(istype(A, /turf))
				forceMove(A)
			else
				forceMove(get_turf(A))
			trajectory_ignore_forcemove = FALSE
			permutated.Add(A)
		return FALSE

	//stop flying
	on_impact(A)

	qdel(src)
	return TRUE

/obj/item/projectile/ex_act(var/severity = 2.0)
	return //explosions probably shouldn't delete projectiles

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/obj/item/projectile/proc/old_style_target(atom/target, atom/source)
	if(!source)
		source = get_turf(src)
	setAngle(get_projectile_angle(source, target))

/obj/item/projectile/proc/fire(angle, atom/direct_target)
	//If no angle needs to resolve it from xo/yo!
	if(direct_target)
		direct_target.bullet_act(src, def_zone)
		on_impact(direct_target)
		qdel(src)
		return
	if(isnum(angle))
		setAngle(angle)
	// trajectory dispersion
	var/turf/starting = get_turf(src)
	if(!starting)
		return
	if(isnull(Angle))	//Try to resolve through offsets if there's no angle set.
		if(isnull(xo) || isnull(yo))
			crash_with("WARNING: Projectile [type] deleted due to being unable to resolve a target after angle was null!")
			qdel(src)
			return
		var/turf/target = locate(Clamp(starting + xo, 1, world.maxx), Clamp(starting + yo, 1, world.maxy), starting.z)
		setAngle(get_projectile_angle(src, target))
	if(dispersion)
		setAngle(Angle + rand(-dispersion, dispersion))
	original_angle = Angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(muzzle_type && !silenced)
		if(ispath(muzzle_type))
			if(firer)
				var/obj/effect/projectile/thing = 	new muzzle_type(get_turf(src))
				if(firer.dir == NORTH)
					thing.plane = LYING_HUMAN_PLANE //Below the mob.
				var/matrix/M = new
				M.Turn(Angle)
				thing.transform = M
				QDEL_IN(thing, 2)

				var/x_component = sin(Angle) * 40
				var/y_component = cos(Angle) * 40
				var/obj/effect/abstract/particle_holder/gun_smoke = new(get_turf(src), /particles/firing_smoke)
				gun_smoke.particles.velocity = list(x_component, y_component)
				QDEL_IN(gun_smoke, 0.4 SECONDS)
	forceMove(starting)
	trajectory = new(starting.x, starting.y, starting.z, 0, 0, Angle, pixel_speed)
	last_projectile_move = world.time
	fired = TRUE
	if(hitscan)
		return process_hitscan()
	else
		filters += filter(type = "blur", size = 1)//Blur the bullet.
		if(prob(50))
			set_light(2,1,"#E38F46")
		if(!is_processing)
			START_PROCESSING(SSprojectiles, src)
		pixel_move(1)	//move it now!

/obj/item/projectile/proc/preparePixelProjectile(atom/target, atom/source, params, angle_offset = 0)
	var/turf/curloc = get_turf(source)
	var/turf/targloc = get_turf(target)
	forceMove(get_turf(source))
	starting = get_turf(source)
	original = target

	var/list/calculated = list(null,null,null)
	if(isliving(source) && params)
		calculated = calculate_projectile_angle_and_pixel_offsets(source, params)
		p_x = calculated[2]
		p_y = calculated[3]
		setAngle(calculated[1])

	else if(targloc && curloc)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		setAngle(get_projectile_angle(src, targloc))
	else
		crash_with("WARNING: Projectile [type] fired without either mouse parameters, or a target atom to aim at!")
		qdel(src)
	if(angle_offset)
		setAngle(Angle + angle_offset)

/obj/item/projectile/proc/before_move()
	return

/obj/item/projectile/proc/after_move()
	return

/obj/item/projectile/Crossed(atom/movable/AM) //A mob moving on a tile with a projectile is hit by it.
	set waitfor = 0
	..()
	if(isliving(AM) && (AM.density || AM == original) && !(pass_flags & PASS_FLAG_MOB))
		Bump(AM)

/obj/item/projectile/Initialize()
	. = ..()
	permutated = list()

/obj/item/projectile/proc/pixel_move(moves, trajectory_multiplier = 1, hitscanning = FALSE)
	if(!loc || !trajectory)
		if(!QDELETED(src))
			if(loc)
				on_impact(loc)
			qdel(src)
		return
	last_projectile_move = world.time
	if(!nondirectional_sprite && !hitscanning)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	trajectory.increment(trajectory_multiplier)
	var/turf/T = trajectory.return_turf()
	if(T?.z != loc?.z)//Wha the fuck is this even used for?
		before_move()
		before_z_change(loc, T)
		trajectory_ignore_forcemove = TRUE
		forceMove(T)
		trajectory_ignore_forcemove = FALSE
		after_move()
		if(!hitscanning)
			pixel_x = trajectory.return_px()
			pixel_y = trajectory.return_py()
	else
		before_move()
		step_towards(src, T)
		after_move()
		if(!hitscanning)
			pixel_x = trajectory.return_px() - trajectory.mpx * trajectory_multiplier
			pixel_y = trajectory.return_py() - trajectory.mpy * trajectory_multiplier
	if(!hitscanning)
		animate(src, pixel_x = trajectory.return_px(), pixel_y = trajectory.return_py(), time = 1, flags = ANIMATION_END_NOW)
	if(isturf(loc))
		hitscan_last = loc
	if(can_hit_target(original, permutated))
		Bump(original, TRUE)
	Range()

//Returns true if the target atom is on our current turf and above the right layer
/obj/item/projectile/proc/can_hit_target(atom/target, var/list/passthrough)
	return (target && ((target.layer >= TURF_LAYER + 0.3) || ismob(target)) && (loc == get_turf(target)) && (!(target in passthrough)))

/proc/calculate_projectile_angle_and_pixel_offsets(mob/user, params)
	var/list/mouse_control = params2list(params)
	var/p_x = 0
	var/p_y = 0
	var/angle = 0
	if(mouse_control["icon-x"])
		p_x = text2num(mouse_control["icon-x"])
	if(mouse_control["icon-y"])
		p_y = text2num(mouse_control["icon-y"])
	if(mouse_control["screen-loc"])
		//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
		var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")

		//Split X+Pixel_X up into list(X, Pixel_X)
		var/list/screen_loc_X = splittext(screen_loc_params[1],":")

		//Split Y+Pixel_Y up into list(Y, Pixel_Y)
		var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
		var/x = text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32
		var/y = text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32

		//Calculate the "resolution" of screen based on client's view and world's icon size. This will work if the user can view more tiles than average.
		var/list/screenview = getviewsize(user.client.view)
		var/screenviewX = screenview[1] * world.icon_size
		var/screenviewY = screenview[2] * world.icon_size

		var/ox = round(screenviewX/2) - user.client.pixel_x //"origin" x
		var/oy = round(screenviewY/2) - user.client.pixel_y //"origin" y
		angle = Atan2(y - oy, x - ox)
	return list(angle, p_x, p_y)

/obj/item/projectile/proc/Range()
	range--
	if(range <= 0 && loc)
		on_range()

/obj/item/projectile/proc/on_range() //if we want there to be effects when they reach the end of their range
	on_impact(loc)
	qdel(src)

/obj/item/projectile/proc/store_hitscan_collision(datum/point/pcache)
	beam_segments[beam_index] = pcache
	beam_index = pcache
	beam_segments[beam_index] = null

/obj/item/projectile/proc/return_predicted_turf_after_moves(moves, forced_angle)		//I say predicted because there's no telling that the projectile won't change direction/location in flight.
	if(!trajectory && isnull(forced_angle) && isnull(Angle))
		return FALSE
	var/datum/point/vector/current = trajectory
	if(!current)
		var/turf/T = get_turf(src)
		current = new(T.x, T.y, T.z, pixel_x, pixel_y, isnull(forced_angle)? Angle : forced_angle, pixel_speed)
	var/datum/point/vector/v = current.return_vector_after_increments(moves)
	return v.return_turf()

/obj/item/projectile/proc/return_pathing_turfs_in_moves(moves, forced_angle)
	var/turf/current = get_turf(src)
	var/turf/ending = return_predicted_turf_after_moves(moves, forced_angle)
	return getline(current, ending)

/obj/item/projectile/proc/process_hitscan()
	var/safety = range * 3
	var/return_vector = RETURN_POINT_VECTOR_INCREMENT(src, Angle, MUZZLE_EFFECT_PIXEL_INCREMENT, 1)
	record_hitscan_start(return_vector)
	while(loc && !QDELETED(src))
		if(paused)
			stoplag(1)
			continue
		if(safety-- <= 0)
			qdel(src)
			crash_with("WARNING: [type] projectile encountered infinite recursion during hitscanning in [__FILE__]/[__LINE__]!")
			return	//Kill!
		pixel_move(1, 1, TRUE)

/obj/item/projectile/proc/record_hitscan_start(datum/point/pcache)
	beam_segments = list()	//initialize segment list with the list for the first segment
	beam_index = pcache
	beam_segments[beam_index] = null	//record start.

/obj/item/projectile/proc/vol_by_damage()
	if(src.damage)
		return Clamp((src.damage) * 0.67, 30, 100)// Multiply projectile damage by 0.67, then CLAMP the value between 30 and 100
	else
		return 50 //if the projectile doesn't do damage, play its hitsound at 50% volume.

/obj/item/projectile/proc/before_z_change(turf/oldloc, turf/newloc)
	var/datum/point/pcache = trajectory.copy_to()
	if(hitscan)
		store_hitscan_collision(pcache)

/obj/item/projectile/Process()
	last_process = world.time

	if(!loc || !fired || !trajectory)
		fired = FALSE
		return PROCESS_KILL
	if(paused || !isturf(loc))
		last_projectile_move += world.time - last_process		//Compensates for pausing, so it doesn't become a hitscan projectile when unpaused from charged up ticks.
		return
	var/elapsed_time_deciseconds = (world.time - last_projectile_move) + time_offset
	time_offset = 0
	var/required_moves = 0
	if(speed > 0)
		required_moves = Floor(elapsed_time_deciseconds / speed, 1)
		if(required_moves > SSprojectiles.global_max_tick_moves)
			var/overrun = required_moves - SSprojectiles.global_max_tick_moves
			required_moves = SSprojectiles.global_max_tick_moves
			time_offset += overrun * speed
		time_offset += Modulus(elapsed_time_deciseconds, speed)
	else
		required_moves = SSprojectiles.global_max_tick_moves
	if(!required_moves)
		return
	for(var/i in 1 to required_moves)
		pixel_move(required_moves)

/obj/item/projectile/proc/setAngle(new_angle)	//wrapper for overrides.
	Angle = new_angle
	if(!nondirectional_sprite)
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
	if(trajectory)
		trajectory.set_angle(new_angle)
	return TRUE

/obj/item/projectile/forceMove(atom/target)
	. = ..()
	if(trajectory && !trajectory_ignore_forcemove && isturf(target))
		trajectory.initialize_location(target.x, target.y, target.z, 0, 0)

/obj/item/projectile/Destroy()
	if(hitscan)
		if(loc && trajectory)
			var/datum/point/pcache = trajectory.copy_to()
			beam_segments[beam_index] = pcache
		generate_hitscan_tracers()
	STOP_PROCESSING(SSprojectiles, src)
	return ..()

/obj/item/projectile/proc/generate_hitscan_tracers(cleanup = TRUE, duration = 1)
	if(!length(beam_segments))
		return
	if(duration <= 0)
		return
	if(tracer_type)
		for(var/datum/point/p in beam_segments)
			generate_tracer_between_points(p, beam_segments[p], tracer_type, color, duration)
	if(muzzle_type && !silenced)
		var/datum/point/p = beam_segments[1]
		var/atom/movable/thing = new /obj/effect/abstract
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(original_angle)
		thing.transform = M
		spawn(duration)
			animate(thing, duration, alpha = 0)
			qdel(thing)
	if(impact_type)
		var/datum/point/p = beam_segments[beam_segments[beam_segments.len]]
		var/atom/movable/thing = new impact_type
		p.move_atom_to_src(thing)
		var/matrix/M = new
		M.Turn(Angle)
		thing.transform = M
		spawn(duration)
			animate(thing, duration, alpha = 0)
			qdel(thing)
	if(cleanup)
		for(var/i in beam_segments)
			qdel(i)
		beam_segments = null
		QDEL_NULL(beam_index)

/proc/get_projectile_angle(atom/source, atom/target)
	var/sx = source.x * world.icon_size
	var/sy = source.y * world.icon_size
	var/tx = target.x * world.icon_size
	var/ty = target.y * world.icon_size
	var/atom/movable/AM
	if(ismovable(source))
		AM = source
		sx += AM.step_x
		sy += AM.step_y
	if(ismovable(target))
		AM = target
		tx += AM.step_x
		ty += AM.step_y
	return SIMPLIFY_DEGREES(arctan(ty - sy, tx - sx))

/obj/item/projectile/after_move()
	..()
	increments++
	check_for_cover()

/obj/item/projectile/proc/check_for_cover()
	if(!(increments > 3))//Bullet has moved at least three tiles by now.
		return
	if(cover_checked)//Cover has been found, don't bother trying to find it anymore.
		return
	if(locate(/obj/structure/flora/tree) in get_turf(loc))
		cover_checked = TRUE
	else if(locate(/obj/structure/dirt_wall) in get_turf(loc))//Search for cover here.
		cover_checked = TRUE
	else if (locate(/obj/structure/warfare/barricade) in get_turf(loc))
		cover_checked = TRUE