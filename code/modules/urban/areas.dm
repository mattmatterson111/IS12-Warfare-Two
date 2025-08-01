/area/warfare/battlefield/trench_section/underground/stormsystem
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "stormsystem"
	sound_env = HANGAR
	music = 'sound/ambience/dungeon.ogg'
	can_pre_enter = 0

/area/warfare/battlefield/trench_section/underground/stormsystem/hall
	icon_state = "stormsystem_hallway"
	sound_env = STONE_CORRIDOR
	music = 'sound/ambience/dungeon.ogg'

/area/warfare/battlefield/trench_section/underground/bunker
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "underground"
	sound_env = STONE_CORRIDOR
	can_pre_enter = 0

// Subtyping underground because it gets rid of the fugly overlay
/area/warfare/battlefield/trench_section/underground/indoors
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "building"
	sound_env = STONE_CORRIDOR
	music = null
	can_pre_enter = 0

/area/warfare/battlefield/no_mans_land/no_mine
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "no_mine"
	turf_initializer = null

/area/warfare/battlefield/capture_point/mid/underground

/area/warfare/battlefield/capture_point/mid/underground/Entered(mob/living/L, area/A)
	. = ..() // STUPID STUPID
	if(istype(L) && !istype(A, /area/warfare/battlefield))
		L.clear_fullscreen("fog")
		L.clear_fullscreen("ash")
		L.clear_fullscreen("ashparticle")