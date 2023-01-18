--!strict
---------
local TypeChecking = {}
-----------------------

type table = {[any]: any}
type array = {any}
type variant = any
type tuple = any

export type TablesPascal = {
	Length: (Table: table) -> number,
	IsArray: (Table: table) -> boolean,
	IsDictionary: (Table: table) -> boolean,
	Update: (Original: table, Update: table, FillEmptyOnly: boolean) -> table,
	Intersect: (Table_1: table, Table_2: table) -> table,
	Difference: (Table_1: table, Table_2: table) -> table,
	GetIndexed: (Table: table, Str: string, Separator: string?) -> any,
	Range: (Array: array, Start: number, End: number, Step: number?) -> array,
	Shuffle: (Array: array) -> array,
	Random: (Table: table) -> any,
	Keys: (Table: table) -> array,
	Values: (Table: table) -> array,
	Filter: (Table: table, Predication: (Key: any, Value: any) -> boolean) -> table,
	Merge: (MergeType: number, Table_1: table, Table_2: table, ...table) -> table,
	WeightedRandomChoice: (Dictionary: {[any]: number}) -> any,
	ParseString: (Str: string, Separator: string?, UseLoadstring: boolean?) -> table,
	ClearRange: (Array: array, Start: number, End: number?) -> array,
	GetTableType: (Table: table) -> string,
	ripairs: (Array: array) -> ((Array: array, Index: number) -> (number, any), array, number),
	Reverse: (Array: array, Method: number?) -> array,
	SearchForNeedle: (Table: table, Needle: any, IsRecursive: boolean?) -> any?,
	SearchAndReplace: (Table: table, Needle: any, Replacement: any?, IsRecursive: boolean?) -> (table, number),
	DeconstructValueObjects: (Ancestor: Instance) -> table,
	ToValueObjects: (Table: table, RootObject: (string | Instance)?, Parent: Instance?, DefaultGroupingObject: string?, Processed: table?) -> Instance,
	Equals: (Table_1: {[any]: any}, Table_2: {[any]: any}, Recursive: boolean?, UseMetamethodEquality: boolean?, Cache: table?) -> boolean,

	--| Standard library's functions:
	Getn: (t: array) -> number,
	ForEachI: (t: table, f: (k: any, v: any) -> ()) -> (),
	ForEach: (t: array, f: (i: any, v: any) -> ()) -> (),
	Sort: (t: array, comp: (a: any, b: any) -> boolean?) -> (),
	Unpack: (list: table, i: number, k: number) -> ...tuple,
	Freeze: (t: table) -> table,
	Clear: (t: table) -> (),
	Pack: (...variant) -> table,
	Move: (src: table, a: number, b: number, t: number, dst: table) -> (),
	Insert: (t: array, posvalue: number | variant, value: variant) -> (),
	--Insert: (t: array, value: variant) -> (),
	Create: (count: number, value: variant) -> table,
	Maxn: (t: table) -> number,
	IsFrozen: (t: table) -> boolean,
	Concat: (t: array, sep: string, i: number, j: number) -> string,
	Clone: (t: table) -> table,
	Find: (haystack: table, needle: variant, init: number) -> variant,
	Remove: (t: array, pos: number) -> variant,
}

export type TablesLowered = {
	length: (table: table) -> number,
	isarray: (table: table) -> boolean,
	isdictionary: (table: table) -> boolean,
	update: (original: table, update: table, fillemptyonly: boolean) -> table,
	intersect: (table_1: table, table_2: table) -> table,
	difference: (table_1: table, table_2: table) -> table,
	getindexed: (table: table, str: string, separator: string?) -> any,
	range: (array: array, start: number, ending: number?, step: number?) -> array,
	shuffle: (array: array) -> array,
	random: (table: table) -> any,
	keys: (table: table) -> array,
	values: (table: table) -> array,
	filter: (table: table, predication: (key: any, value: any) -> boolean) -> table,
	merge: (mergetype: number, table_1: table, table_2: table, ...table) -> table,
	weightedrandomchoice: (dictionary: {[any]: number}) -> any,
	parsestring: (str: string, separator: string?, useloadstring: boolean?) -> table,
	clearrange: (array: array, start: number, ending: number?) -> array,
	gettabletype: (table: table) -> string,
	ripairs: (array: array) -> ((array: array, index: number) -> (number, any), array, number),
	reverse: (array: array, method: number?) -> array,
	searchforneedle: (table: table, needle: any, isrecursive: boolean?) -> any?,
	searchandreplace: (table: table, needle: any, replacement: any?, isrecursive: boolean?) -> (table, number),
	deconstructvalueobjects: (ancestor: Instance) -> table,
	tovalueobjects: (table: table, rootobject: (string | Instance)?, parent: Instance?, defaultgroupingobject: string?, processed: table?) -> Instance,
	equals: (table_1: {[any]: any}, table_2: {[any]: any}, recursive: boolean?, usemetamethodequality: boolean?, cache: table?) -> boolean,

	--| Standard library's functions:
	getn: (t: array) -> number,
	foreachi: (t: table, f: (k: any, v: any) -> ()) -> (),
	foreach: (t: array, f: (i: any, v: any) -> ()) -> (),
	sort: (t: array, comp: (a: any, b: any) -> boolean?) -> (),
	unpack: (list: table, i: number, k: number) -> ...tuple,
	freeze: (t: table) -> table,
	clear: (t: table) -> (),
	pack: (...variant) -> table,
	move: (src: table, a: number, b: number, t: number, dst: table) -> (),
	insert: (t: array, pos: number | variant, value: variant) -> (),
	--insert: (t: array, value: variant) -> (),
	create: (count: number, value: variant) -> table,
	maxn: (t: table) -> number,
	isfrozen: (t: table) -> boolean,
	concat: (t: array, sep: string, i: number, j: number) -> string,
	clone: (t: table) -> table,
	find: (haystack: table, needle: variant, init: number) -> variant,
	remove: (t: array, pos: number) -> variant,
}

return TypeChecking