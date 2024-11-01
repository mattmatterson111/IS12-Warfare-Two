/datum
	// Abstract types are expanded upon more in __DEFINES\abstract.dm
	/// If this var's value is equivalent to the current type, it is considered abstract.
	/// It is illegal to instantiate abstract types.
	var/datum/abstract_type = /datum


/**
* Abstract-ness is a meta-property of a class that is used to indicate
* that the class is intended to be used as a base class for others, and
* should not (or cannot) be instantiated.
* We have no such language concept in DM, and so we provide a datum member
* that can be used to hint at abstractness for circumstances where we would
* like that to be the case, such as base behavior providers.
*/

//This helper is underutilized, but that's a problem for me later. -Francinum

/// TRUE if the current path is abstract. See __DEFINES\abstract.dm for more information.
/// Instantiating abstract paths is illegal.
#define isabstract(foo) (ispath(foo) ? foo == initial(foo.abstract_type) : foo.type == foo.abstract_type)
