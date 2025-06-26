/area/warfare/battlefield/trench_section/underground/stormsystem
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "stormsystem"
	sound_env = HANGAR
	music = 'sound/ambience/dungeon.ogg'

/area/warfare/battlefield/trench_section/underground/stormsystem/hall
	icon_state = "stormsystem_hallway"
	sound_env = STONE_CORRIDOR
	music = 'sound/ambience/dungeon.ogg'

/area/warfare/battlefield/trench_section/underground/bunker
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "underground"
	sound_env = STONE_CORRIDOR

// Subtyping underground because it gets rid of the fugly overlay
/area/warfare/battlefield/trench_section/underground/indoors
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "indoors"
	sound_env = STONE_CORRIDOR
	music = null

/area/warfare/battlefield/no_mans_land/no_mine
	icon = 'icons/turf/urban/areas.dmi'
	icon_state = "no_mine"
	turf_initializer = null