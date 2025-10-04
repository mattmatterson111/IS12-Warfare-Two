/*This file is a list of all preclaimed planes & layers

All planes & layers should be given a value here instead of using a magic/arbitrary number.

After fiddling with planes and layers for some time, I figured I may as well provide some documentation:

What are planes?
	Think of Planes as a sort of layer for a layer - if plane X is a larger number than plane Y, the highest number for a layer in X will be below the lowest
	number for a layer in Y.
	Planes also have the added bonus of having planesmasters.

What are Planesmasters?
	Planesmasters, when in the sight of a player, will have its appearance properties (for example, colour matrices, alpha, transform, etc)
	applied to all the other objects in the plane. This is all client sided.
	Usually you would want to add the planesmaster as an invisible image in the client's screen.

What can I do with Planesmasters?
	You can: Make certain players not see an entire plane,
	Make an entire plane have a certain colour matrices,
	Make an entire plane transform in a certain way,
	Make players see a plane which is hidden to normal players - I intend to implement this with the antag HUDs for example.
	Planesmasters can be used as a neater way to deal with client images or potentially to do some neat things

How do planes work?
	A plane can be any integer from -100 to 100. (If you want more, bug lummox.)
	All planes above 0, the 'base plane', are visible even when your character cannot 'see' them, for example, the HUD.
	All planes below 0, the 'base plane', are only visible when a character can see them.

How do I add a plane?
	Think of where you want the plane to appear, look through the pre-existing planes and find where it is above and where it is below
	Slot it in in that place, and change the pre-existing planes, making sure no plane shares a number.
	Add a description with a comment as to what the plane does.

How do I make something a planesmaster?
	Add the PLANE_MASTER appearance flag to the appearance_flags variable.

What is the naming convention for planes or layers?
	Make sure to use the name of your object before the _LAYER or _PLANE, eg: [NAME_OF_YOUR_OBJECT HERE]_LAYER or [NAME_OF_YOUR_OBJECT HERE]_PLANE
	Also, as it's a define, it is standard practice to use capital letters for the variable so people know this.

*/

/*
	from stddef.dm, planes & layers built into byond.

	FLOAT_LAYER = -1
	AREA_LAYER = 1
	TURF_LAYER = 2
	OBJ_LAYER = 3
	MOB_LAYER = 4
	FLY_LAYER = 5
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	------

	FLOAT_PLANE = -32767
*/
// honestly, its not optimal, it's shit, but I just wanted space to easily add new planes if I wanted to

#define CLICKCATCHER_PLANE           -340
#define HIDDEN_SHIT_PLANE            -330
#define SPACE_PLANE                  -320
#define SKYBOX_PLANE                 -310

#define DUST_PLANE                   -300
    #define DEBRIS_LAYER            1
    #define DUST_LAYER              2

#define UNDER_OPENSPACE_PLANE        -210
#define OPENSPACE_PLANE              -200
#define BELOW_TURF_PLANE             -190

#define PLATING_PLANE                -180
    #define PLATING_LAYER           1

#define ABOVE_PLATING_PLANE          -170
    #define HOLOMAP_LAYER           2
    #define DECAL_PLATING_LAYER     3
    #define DISPOSALS_PIPE_LAYER    4
    #define LATTICE_LAYER           5
    #define PIPE_LAYER              6
    #define WIRE_LAYER              7
    #define WIRE_TERMINAL_LAYER     8
    #define ABOVE_WIRE_LAYER        9

#define OVER_OPENSPACE_PLANE         -170  // Placed above openspace range

#define TURF_PLANE                   -160
    #define BASE_TURF_LAYER         -999
    #define TURF_DETAIL_LAYER       11

#define WALL_PLANE                   -150

#define ABOVE_TURF_PLANE             -140
    #define DECAL_LAYER             12
    #define RUNE_LAYER              13
    #define ABOVE_TILE_LAYER        14
    #define EXPOSED_PIPE_LAYER      15
    #define EXPOSED_WIRE_LAYER      16
    #define EXPOSED_WIRE_TERMINAL_LAYER 17
    #define CATWALK_LAYER           18
    #define BLOOD_LAYER             19
    #define MOUSETRAP_LAYER         20
    #define PLANT_LAYER             21
    #define AO_LAYER                22

#define HIDING_MOB_PLANE             -130
    #define HIDING_MOB_LAYER        0

#define OBJ_PLANE                    -120
    #define BELOW_DOOR_LAYER        23
    #define OPEN_DOOR_LAYER         24
    #define BELOW_TABLE_LAYER       25
    #define TABLE_LAYER             26
    #define BELOW_OBJ_LAYER         27
    #define BASE_OBJ_LAYER          28
    #define ABOVE_OBJ_LAYER         29
    #define CLOSED_DOOR_LAYER       30
    #define ABOVE_DOOR_LAYER        31
    #define SIDE_WINDOW_LAYER       32
    #define FULL_WINDOW_LAYER       33
    #define ABOVE_WINDOW_LAYER      34

#define LYING_MOB_PLANE              -110
    #define LYING_MOB_LAYER         35

#define LYING_HUMAN_PLANE            -100
    #define LYING_HUMAN_LAYER       36

#define ABOVE_OBJ_PLANE              -90
    #define BASE_ABOVE_OBJ_LAYER    37

#define HUMAN_PLANE                  -80
    #define BASE_MOB_LAYER          38

#define ANON_PLANE                   -75  // Anonymous blur effect

#define MOB_PLANE                    -70  // For non-human mobs

#define ABOVE_HUMAN_PLANE            -60
    #define ABOVE_HUMAN_LAYER       39
    #define VEHICLE_LOAD_LAYER      40
    #define CAMERA_LAYER            41

#define BLOB_PLANE                   -55
    #define BLOB_SHIELD_LAYER		42
    #define BLOB_NODE_LAYER			43
    #define BLOB_CORE_LAYER			44

#define BULLET_PLANE                 -50  // Bullets in combat

#define EFFECTS_BELOW_LIGHTING_PLANE -40
    #define BELOW_PROJECTILE_LAYER  45
    #define FIRE_LAYER              46
    #define PROJECTILE_LAYER        47
    #define ABOVE_PROJECTILE_LAYER  48
    #define SINGULARITY_LAYER       49
    #define POINTER_LAYER           50

#define BLURRED_EFFECTS_PLANE -39 // Reserved for blurred effects/particles, eg: smoke

#define OBSERVER_PLANE               -30  // For observers and ghosts

#define DARKNESS_PLANE				 -19
#define LIGHTING_PLANE               -20
    #define LIGHTBULB_LAYER         0
    #define ABOVE_LIGHTING_LAYER    2
    #define SUPER_PORTAL_LAYER      3
    #define NARSIE_GLOW             4

#define EFFECTS_ABOVE_LIGHTING_PLANE -10
    #define EYE_GLOW_LAYER          1
    #define BEAM_PROJECTILE_LAYER   2
    #define SUPERMATTER_WALL_LAYER  3

#define GLOW_PLANE 					 -6  // What feeds into those two below, basically a combo
#define GLARE_PLANE                  -5  // Lens flare and glare overlays
#define BLOOM_PLANE                  -4  // Bloom/glow pass effects

#define EXPOSURE_PLANE -3 // Exposure plane for lights, don't worry about it

#define BASE_PLANE 				        0 // Not for anything, but this is the default.
	#define BASE_AREA_LAYER 999

#define OBSCURITY_PLANE 		        2 // visualnets?

#define FULLSCREEN_PLANE                3 // for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER    0
	#define SCREEN_DAMAGE_LAYER        1
	#define IMPAIRED_LAYER      2
	#define BLIND_LAYER         3
	#define CRIT_LAYER          4
	#define HALLUCINATION_LAYER 5

#define ABOVE_FULLSCREEN_PLANE 			4

#define VISION_CONE_PLANE               5 // For the vision cone.

#define FOOTSTEP_ALERT_PLANE            6 // Hacky fix for the footsteps not being a thing.

#define HUD_PLANE                       7 // For the Head-Up Display

	#define UNDER_HUD_LAYER      0
	#define HUD_BASE_LAYER       1
	#define HUD_ITEM_LAYER       2
	#define HUD_ABOVE_ITEM_LAYER 3

//This is difference between highest and lowest visible
#define PLANE_DIFFERENCE              22 // unused.
/image
	plane = FLOAT_PLANE			// this is defunct, lummox fixed this on recent compilers, but it will bug out if I remove it for coders not on the most recent compile.

/image/proc/plating_decal_layerise()
	plane = ABOVE_PLATING_PLANE
	layer = DECAL_PLATING_LAYER

/image/proc/turf_decal_layerise()
	plane = ABOVE_TURF_PLANE
	layer = DECAL_LAYER

/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)

/*
  PLANE MASTERS
*/

/obj/blur_planemaster
	appearance_flags = PLANE_MASTER
	plane = OPENSPACE_PLANE
	screen_loc = "1,1"

/obj/blur_planemaster/New()
	..()
	filters += filter(type = "blur", size = 1)

//I don't know what the fuck this shit is used for.
/obj/screen/plane_master
	appearance_flags = PLANE_MASTER
	screen_loc = "CENTER,CENTER"
	globalscreen = 1

/obj/screen/plane_master/blur
	var/size = 2

/obj/screen/plane_master/blur/New()
	..()
	if (size)
		filters += filter(type = "blur", size = size)

/obj/screen/plane_master/blur/ghost_master
	plane = OBSERVER_PLANE
	size = 1

/obj/screen/plane_master/blur/bullet_plane
	plane = BULLET_PLANE
	size = 1

/obj/screen/plane_master/blur/human_blur
	plane = HUMAN_PLANE

/obj/screen/plane_master/blur/turf_blur
	plane = TURF_PLANE

/obj/screen/plane_master/blur/wall_blur
	plane = WALL_PLANE

/obj/screen/plane_master/blur/obj_blur
	plane = OBJ_PLANE

/obj/screen/plane_master/blur/lhuman_blur
	plane = LYING_HUMAN_PLANE

/obj/screen/plane_master/blur/mob_blur
	plane = MOB_PLANE

/obj/screen/plane_master/blur/above_human_blur
	plane = ABOVE_HUMAN_PLANE

/obj/screen/plane_master/blur/above_turf_blur
	plane = ABOVE_TURF_PLANE

/obj/screen/plane_master/blur/above_obj_blur
	plane = ABOVE_OBJ_PLANE

/obj/screen/plane_master/blur/plating_blur
	plane = PLATING_PLANE

/obj/screen/plane_master/blur/effects_blur
	plane = BLURRED_EFFECTS_PLANE

/obj/screen/plane_master/ghost_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	alpha = 0
	appearance_flags = 0
	plane = OBSERVER_PLANE

GLOBAL_LIST_INIT(ghost_master, list(
	new /obj/screen/plane_master/blur/ghost_master(),
	new /obj/screen/plane_master/ghost_dummy()
))

/obj/screen/plane_master/lights_filterer
	render_target = "*TO_LIGHTFILT"

/obj/screen/plane_master/bloom_filter
	name = "bloom filter"
	plane = BLOOM_PLANE
	layer = FLOAT_LAYER

/obj/screen/plane_master/bloom_filter/Initialize()
	..()
	filters += filter(type = "layer", render_source = "*TO_LIGHTFILT")
	filters += filter(type = "bloom", size = 5, offset = 2, alpha = 90)


/obj/screen/plane_master/radial_filter
	name = "radial blur filter"
	plane = GLARE_PLANE

/obj/screen/plane_master/radial_filter/Initialize()
	..()
	filters += filter(type = "layer", render_source = "*TO_LIGHTFILT")
	filters += filter(type = "radial_blur", size = 0.02)

/obj/screen/plane_master/exposure_filter
	name = "exposure filter plane"
	alpha = 25
	plane = EXPOSURE_PLANE
	blend_mode = BLEND_ADD

/obj/screen/plane_master/exposure_filter/Initialize()
	..()

	filters += filter(type = "blur", size = 20)
	//filters += filter(type = "bloom", size = 10, offset = 2, alpha = 100)


/obj/screen/plane_master/ao
	// no vars set, here to make searching easier

/obj/screen/plane_master/ao/New()
	..()
	filters += filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")

/obj/screen/plane_master/ao/human
	plane = HUMAN_PLANE

/obj/screen/plane_master/ao/wall
	plane = WALL_PLANE

/obj/screen/plane_master/ao/object
	plane = OBJ_PLANE

/obj/screen/plane_master/ao/lying_human
	plane = LYING_HUMAN_PLANE

/obj/screen/plane_master/ao/mobao
	plane = MOB_PLANE

/obj/screen/plane_master/vision_cone_target
	name = "vision cone master"
	plane = HIDDEN_SHIT_PLANE
	render_target = "vision_cone_target"

/obj/screen/plane_master/vision_cone_blender
	render_target = "vision_cone_target"

//A series of vision related masters. They all have the same RT name to lower load on client.
/obj/screen/plane_master/vision_cone/

/obj/screen/plane_master/vision_cone/primary/Initialize() //For when you want things to not appear under the blind section.
	. = ..()
	filters += filter(type="alpha", render_source="vision_cone_target", flags=MASK_INVERSE)

/obj/screen/plane_master/vision_cone/inverted //for things you want specifically to show up on the blind section.


/obj/screen/plane_master/vision_cone/inverted/Initialize()
	. = ..()
	filters += filter(type="alpha", render_source="vision_cone_target")