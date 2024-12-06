//See controllers/globals.dm
#define GLOBAL_MANAGED(X, InitValue)\
/datum/controller/global_vars/proc/InitGlobal##X(){\
	##X = ##InitValue;\
	gvars_datum_init_order += #X;\
}
#define GLOBAL_UNMANAGED(X, InitValue) /datum/controller/global_vars/proc/InitGlobal##X()

#ifndef TESTING
#define GLOBAL_PROTECT(X)\
/datum/controller/global_vars/InitGlobal##X(){\
	..();\
	gvars_datum_protected_varlist += #X;\
}
#else
#define GLOBAL_PROTECT(X)
#endif

#define GLOBAL_REAL_VAR(X) var/global/##X
#define GLOBAL_REAL(X, Typepath) var/global##Typepath/##X

#define GLOBAL_RAW(X) /datum/controller/global_vars/var/global##X

#define GLOBAL_VAR_INIT(X, InitValue) GLOBAL_RAW(/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_VAR_CONST(X, InitValue) GLOBAL_RAW(/const/##X) = InitValue; GLOBAL_UNMANAGED(X, InitValue)

#define GLOBAL_LIST_INIT(X, InitValue) GLOBAL_RAW(/list/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_LIST_EMPTY(X) GLOBAL_LIST_INIT(X, list())

#define GLOBAL_DATUM_INIT(X, Typepath, InitValue) GLOBAL_RAW(Typepath/##X); GLOBAL_MANAGED(X, InitValue)

#define GLOBAL_VAR(X) GLOBAL_RAW(/##X); GLOBAL_MANAGED(X, null)

#define GLOBAL_LIST(X) GLOBAL_RAW(/list/##X); GLOBAL_MANAGED(X, null)

#define GLOBAL_DATUM(X, Typepath) GLOBAL_RAW(Typepath/##X); GLOBAL_MANAGED(X, null)


//Im tired as fuck so im just going to put this shit in here i will find a much better place for it later -Presidente/
// Callback macros for 515 compatibility, credit to CM for giving me the idea to if/else this for backwards compatibility as well

#if DM_VERSION < 515

#define GLOB_PROC(NAME) (/proc/##NAME)

#define PROC(NAME) (.proc/##NAME)

#define PROC_BY_TYPE(PATH, NAME) (##PATH.proc/##NAME)

#define VERB(NAME) (.verb/##NAME)

#define VERB_BY_TYPE(PATH, NAME) (##PATH.verb/##NAME)

#define LIBCALL call

#else

#define GLOB_PROC(NAME) (/proc/##NAME)

#define PROC(NAME) (nameof(.proc/##NAME))

#define PROC_BY_TYPE(PATH, NAME) (nameof(##PATH.proc/##NAME))

#define PROC_BY_TYPE_UNSAFE(PATH, NAME) (nameof(##PATH::proc/##NAME))

#define VERB(NAME) (nameof(.verb/##NAME))

#define VERB_BY_TYPE(PATH, NAME) (nameof(##TYPE.verb/##NAME))

#define LIBCALL call_ext

#endif