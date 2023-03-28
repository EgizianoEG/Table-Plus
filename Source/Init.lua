--!strict
---------
--[[ Information:
		○ Author: @EgizianoEG
		○ About:
			- A module that provides extended table-related functions beyond those in the standard library.
			- Inspired by tablex [Module] by Penlight
]]
---------------------------------------------------------------------------------------------------------------------|
local Tables = {}
local MockupStandardLibrary = true		--| table.pack, table.insert, etc.. are integrated.
local LowerCaseFunctionNames = true		--| "testfunction()".
local IncludeSubLibraryFunctions = true	--| Integrate its functions? (Not as a table)
local TypeChecking = require(script.TypeChecking)

type table = {[any]: any}
type array = {[number]: any}
--------------------------------------------------------------------------------------------------------|
--| Utility Functions:
----------------------

--| Returns the number of elements in the given Tables.
function Tables.Length(Table: table): number
	assert(type(Table) == "table", "Invalid Argument [1]; Table expected.")
	----------------------------------------------------------------------|

	local Count = 0
	for _ in pairs(Table) do
		Count += 1
	end
	return Count
end

--| A simple function checking if the given table is an array based on length.
function Tables.IsArray(Table: table): boolean
	if type(Table) ~= "table" then return false end
	local Count = Tables.Length(Table)
	return #Table == Count
end

--| Is a table considered a dictionary?
function Tables.IsDictionary(Table: table): boolean
	local TableType = Tables.GetTableType(Table)
	return TableType == "Dictionary" or TableType == "Mixed"
end

--[[ Update - Updates the values of a table with the values from another Tables.
---| This function updates the values of the Original table with the values from the Update Tables.
---| If the FillEmptyOnly parameter is set to true, only keys that are nil in the Original table will be updated.
---| Otherwise, all keys in the Original table will be updated with the corresponding values from the Update Tables.
-| @param Original: The original table to be updated.
-| @param Update: The table containing the updated values.
-| @param FillEmptyOnly: A boolean value indicating whether to update only keys that are nil in the Original Tables.
-| @return The updated Original Tables.]]
function Tables.Update(Original: table, Update: table, FillEmptyOnly: boolean): (table)
	assert(type(Original) == "table", "Invalid Argument [1]; \"Original\" must be a table")
	assert(type(Update) == "table", "Invalid Argument [2]; \"Update\" must be a table")
	--------------------------------------------------------------------------------------|
	for Key, Value in pairs(Update) do
		if FillEmptyOnly then
			if Original[Key] == nil then
				Original[Key] = Value
			end
		else
			Original[Key] = Value
		end
	end
	return Original
end

--[[ Intersect - Returns a table of elements that are present in both Table_1 and Table_2.
-| @param	Table_1: The first table to compare.
-| @param	Table_2: The second table to compare.
-| @param   ShouldMatchValues: Should the function only return the key-value pairs if the value is the same on the other table?
-| @return	A table of elements that are present in both Table_1 and Table_2.]]
function Tables.Intersect(Table_1: table, Table_2: table, ShouldMatchValues: boolean?): (table)
	assert(type(Table_1) == "table", "Invalid Argument [1]; Table expected.")
	assert(type(Table_2) == "table", "Invalid Argument [2]; Table expected.")
	-------------------------------------------------------------------------|

	ShouldMatchValues = (ShouldMatchValues ~= nil and ShouldMatchValues) or true
	local Intersect = {}
	if Tables.IsArray(Table_1) and Tables.IsArray(Table_2) then
		for _, Element in ipairs(Table_1) do
			if table.find(Table_2, Element) then
				Intersect[#Intersect+1] = Element
			end
		end
	else
		for Key, Value in pairs(Table_1) do
			if Table_2[Key] then
				if ShouldMatchValues then
					if Table_2[Key] == Value then
						Intersect[Key] = Value
					end
				else
					Intersect[Key] = Value
				end
			end
		end
	end
	return Intersect
end

--[[ Difference - Returns a table of elements that are NOT present in both any of the tables provided compared to the other one (like if there was a specific key that is not found on the compared table).
-| @param	Table_1: The first table to compare.
-| @param	Table_2: The second table to compare.
-| @return	A table of elements that are unique to each input Tables.]]
function Tables.Difference(Table_1: table, Table_2: table): (table)
	assert(type(Table_1) == "table", "Invalid Argument [1]; Table expected.")
	assert(type(Table_2) == "table", "Invalid Argument [2]; Table expected.")
	-------------------------------------------------------------------------|

	local Difference = {}
	if Tables.IsArray(Table_1) and Tables.IsArray(Table_2) then
		for _, Element in ipairs(Table_1) do
			if not table.find(Table_2, Element) then
				Difference[#Difference+1] = Element
			end
		end
		for _, Element in ipairs(Table_2) do
			if not table.find(Table_1, Element) then
				Difference[#Difference+1] = Element
			end
		end
	else
		for Key, Value in pairs(Table_1) do
			if Table_2[Key] == nil then
				Difference[Key] = Value
			end
		end
		for Key, Value in pairs(Table_2) do
			if Table_2[Key] == nil then
				Difference[Key] = Value
			end
		end
	end
	return Difference
end

--[[ GetIndexed - Returns the value of the indexed element in a table (parsing string indexing).
-| @param	Table: The table to search.
-| @param	Str: The stringified index of the element to return.
-| @param	Separator: The separator used to split the stringified index. Defaults to ".".
-| @return	The value of the indexed element, or nil/lates found value if the element does not exist.]]
function Tables.GetPathValue(Table: table, Str: string, Separator: string?): (any)
	assert(type(Table) == "table", "Invalid Argument [1]; Table expected.")
	assert(type(Str) == "string", "Invalid Argument [2]; Must be a string.")
	assert(type(Separator) == "string" or Separator == nil, "Invalid Argument [3]; Separator be a string.")
	------------------------------------------------------------------------------------------------------|

	local NumericIndexPattern = ("^%[(%d+)%]$")         --| e.g. Table.[1].[2]
	local Keys = string.split(Str, (Separator or "."))
	local Latest = Table[Keys[1]]
	table.remove(Keys, 1)

	for _, Key in ipairs(Keys) do
		local NumericIndex = string.match(Key, NumericIndexPattern)
		if NumericIndex then
			Key = tonumber(NumericIndex)::any
		end

		if type(Latest) == "table" then
			Latest = Latest[Key]
		else
			break
		end
	end
	return Latest
end

--[[ Range - Returns a range of values from an array.
-| @param   Array: the array to get values from
-| @param   Start: the starting index of the range
-| @param   End: the ending index of the range
-| @param   Step (optional): the step size for the range, defaults to 1
-| @return  a new array containing the values in the specified range]]
function Tables.Range(Array: array, Start: number, End: number, Step: number?)
	local Range = {}
	local Last = #Array
	End = End <= #Array and End or Last
	Start = Start > 0 and Start or 1
	for i = Start, End, (Step or 1) do
		if i > Last then
			break
		end
		Range[#Range+1] = Array[i]
	end
	return Range
end

--[[ Shuffle - Returns the input array shuffled.
-| @param   Array: The array to shuffle.
-| @return  The shuffled array]]
function Tables.Shuffle(Array: array)
	local Length = #Array
	for i = Length, 1, -1 do
		local Rand = math.random(Length)
		Array[i], Array[Rand] = Array[Rand], Array[i]
	end
	return Array
end

--[[ Random - Returns a random key of the input Table.
-| @param   Table: The table to get a random key from.
-| @return  The random key]]
function Tables.Random(Table: table)
	local Keys = Tables.Keys(Table)
	local Randomized = Keys[math.random(1, #Keys)]
	return Table[Randomized]
end

--[[ Keys - Returns an array of the keys in Table.
-| @param   Table: The table to get its keys.
-| @return  The input table's keys array.]]
function Tables.Keys(Table: table)
	local Keys = {}
	for Key in pairs(Table) do
		Keys[#Keys+1] = Key
	end
	return Keys
end

--[[ Values - Returns an array of the values in the provided Table.
-| @param   Table: The table to get its values.
-| @return  The input table's values inside an array.]]
function Tables.Values(Table: table)
	local Values = {}
	for _, Value in pairs(Table) do
		Values[#Values+1] = Value
	end
	return Values
end

--[[ Filter - Returns a new table containing the elements of the original table that match the given `Predication` function.
-| @param   Table: The table to filter.
-| @param   Predication: A function that takes a key and a value from the original table as its arguments and returns a boolean indicating whether or not the element should be included in the filtered Tables.
-| @return  A new table containing the elements of the original table that match the given `Predication` function.]]
function Tables.Filter(Table: table, Predication: (Key: any, Value: any) -> (boolean))
	local Filtered = {}
	for Key, Value in pairs(Table) do
		if Predication(Key, Value) then
			Filtered[Key] = Value
		end
	end
	return Filtered
end

--[[ Merge - Merges two or more tables together.
-| @param   MergeType: Type of merge to perform. 1 or nil: returns an array containing all the provided tables.
-| @param   Table_1: First table to merge.
-| @param   Table_2: Second table to merge.
-| @param   ...: Additional tables to merge.
-| @return  Merged Tables.]]
function Tables.Merge(MergeType: number?, Table_1: table, Table_2: table, ...: table)
	local Merged = nil
	if MergeType == 1 or MergeType == nil then
		Merged = {Table_1, Table_2, ...}
	elseif MergeType == 2 then
		local Tables = {Table_1, Table_2, ...}
		for _, Table in ipairs(Tables) do
			for Key, Value in Table do
				Merged[Key] = Value
			end
		end
	else
		local Tables = {Table_1, Table_2, ...}
		for _, Table in ipairs(Tables) do
			for Key, Value in pairs(Table) do
				if not Merged[Key] then
					Merged[Key] = Value
				end
			end
		end
	end
	return Merged
end

--[[ WeightedRandomChoice - Returns a random key from the given dictionary, with a probability of selection for each key proportional to the value associated with that key.
-| @param   Dictionary: A table mapping keys to weights.
-| @return  A random key from the dictionary.]]
function Tables.WeightedRandomChoice(Dictionary: {[any]: number})
	local Chance
	local CumulativeWeight = 0

	for _, Weight in pairs(Dictionary) do
		CumulativeWeight += Weight
	end

	Chance = math.random(CumulativeWeight)
	CumulativeWeight = 0

	for Key, Weight in Dictionary do
		CumulativeWeight += Weight
		if CumulativeWeight >= Chance then
			return Key
		end
	end
	return nil
end

--[[ ParseString - Parse a string and return a table.
-| @param   Str: The string to be parsed. Can contain numbers, strings, and nested tables.
-| @param   Separator: The separator character used to separate elements in the string. (Note: Do not use separator characters within any provided key-value especially with nested tables otherwise it will give inaccurate results)
-| @return  A table representation of the given string.
-| @example ParseString("'Hello World', test1, 1, 2") -> {[1] = "HelloWorld", [2] = "test1", [3] = 1, [4] = 2} ]]
function Tables.ParseString(Str: string, Separator: string?)
	assert(type(Str) == "string", "Invalid Argument [1]; String expected.")
	assert((type(Separator) == "string" and #Separator > 0) or Separator == nil, "Invalid Argument [2]; Separator string expected.")
	---------------------------------------------------------------------------------------------------------------------|

	local Separator = (Separator or ",")
	local KeyValuePattern = "%s*%[?[\"']?(.-)[\"']?%]?%s*=%s*[\"']?(.+)[\"']?%s*"
	local StringValuePattern = "^%s*%[?[\"']?(.-)[\"']?%]?%s*$"
	local TablePattern = "[" .. Separator .. "]*%s*([^" .. Separator .. "]+%s*=%s*{.+}%s*)"
	local TableKVPattern = "%[?[\"']?(.-)[\"']?%]?%s*=%s*{(.+)}"

	local Table: any = {}
	local NMatches:{{string | number}}= {}
	Str = string.match(Str, "^{?%s*(.-)%s*}?$")
	
	for NestedTable in string.gmatch(Str, TablePattern) do
		local Starting, Ending = string.find(Str, NestedTable, (NMatches[#NMatches] and NMatches[#NMatches][3]::number - 1) or 1, true)
		if Starting and Ending then
			NMatches[#NMatches+1] = {NestedTable, Starting, Ending}
		end
	end
		
	for _, MatchingTable in ipairs(NMatches) do
		local Pairs, Starting: any, Ending: any = MatchingTable[1], MatchingTable[2], MatchingTable[3]
		local Key, Value = string.match(Pairs::string, TableKVPattern)
		Table[string.gsub(Key, "[ " .. Separator .. "\"']+", "")] = Tables.ParseString(Value, Separator)
		Str = (string.sub(Str, 1, Starting-1) .. string.sub(Str, Ending+1))
	end
	
	for Sub in string.gmatch(Str, "([^".. Separator .."]+)") do
		local IsBlank = string.match(Sub, "^%s*$") ~= nil
		local NumberValue = tonumber(Sub)
		local StringValue = string.match(Sub, StringValuePattern)
		local Key, Value = string.match(Sub, KeyValuePattern)
		
		if IsBlank then
			continue
			
		elseif NumberValue then
			Table[#Table+1] = NumberValue

		elseif StringValue and not string.match(Sub, "=") then
			Sub = string.match(Sub, "^%s*%[?[\"']?(.-)[\"']?%]?%s*$")
			Table[#Table+1] = Sub

		elseif Key and Value then
			Key = tonumber(Key) or Key
			Value = tonumber(Value) or Value
			Table[Key] = Value
		end
	end
	return Table
end

--[[ ClearRange - Removes a range of elements from an array.
-| @param	Array: The array from which to remove the elements.
-| @param	Start: The index of the first element to remove.
-| @param	End: The index of the last element to remove. Defaults to the end of the array.
-| @return	The modified array.]]
function Tables.ClearRange(Array: array, Start: number, End: number?): (array)
	assert(type(Array) == "table" and Tables.IsArray(Array), "Invalid Argument [1]; Array expected.")
	assert(type(Start) == "number" and type(End) == "number", "Invalid Range Arguments. Start and End arguments must be numbers.")
	-----------------------------------------------------------------------------------------------------------------------------|

	if Start < 1 then
		Start = 1
	elseif Start > #Array then
		return Array
	end


	End = (End == nil and #Array) or (End > #Array and #Array)::number
	if Start == 1 and End == #Array then return {} end
	for i = End, Start, -1 do
		table.remove(Array, i)
	end
	return Array
end

--[[ GetTableType - Returns the type of the given Tables.
-| @param	Table: The table to get the type of.
-| @return	string - The type of the Tables. Can be one of: "Empty", "Array", "Dictionary", "Mixed", or the type of the value if Table is not a Tables.]]
function Tables.GetTableType(Table: table): (string)
	if type(Table) ~= "table" then return typeof(Table)
	elseif next(Table) == nil then return "Empty" end

	local IsArray = true
	local IsDictionary = true

	for Index in pairs(Table) do
		if type(Index) == "number" and Index % 1 == 0 and Index > 0 then
			IsDictionary = false
		else
			IsArray = false
		end
	end

	if IsArray then
		return "Array"
	elseif IsDictionary then
		return "Dictionary"
	else
		return "Mixed"
	end
end

--[[ Returns an iterator function that returns the elements of a given array in reverse order, starting from the highest index.
-| @param	Array: The array to iterate.
-| @return	An iterator function]]
function Tables.ripairs(Array: array)
	return function(Array, Index: number)
		Index = Index - 1
		if Index ~= 0 then
			return Index, Array[Index]
		else
			return nil::any, nil
		end
	end, Array, #Array + 1
end

--[[ Returns a reversed version of an array.
-| @param	Array: The array to reverse its elements order
-| @param 	Method (optional): method to use for reversing the array (1, 2, or anything other. Default: 1)
-| @return	a reversed array]]
function Tables.Reverse(Array: array, Method: number?)
	assert(type(Array) == "table" and Tables.IsArray(Array), "Invalid Argument [1]; Array expected.")
	assert(type(Method) == "number" or Method == nil, "Invalid Argument [1]; Array expected.")
	------------------------------------------------------------------------------------------------|

	local Method = Method or 1
	if Method == 1 then
		local Reversed = {}
		for i = #Array, 1, -1 do
			Reversed[#Reversed+1] = Array[i]
		end
		return Reversed
	elseif Method == 2 then
		local Middle, End = math.floor(#Array * 0.5), #Array
		for i = 1, Middle do
			Array[i], Array[End - i + 1] = Array[End - i + 1], Array[i]
		end
		return Array
	else
		local Reversed = {}
		local Elements = #Array
		for Index, Value in ipairs(Array) do
			Reversed[(Elements + 1) - Index] = Value
		end
		return Reversed
	end
end

--[[ SearchForNeedle - Searches for the given needle in the given table and returns the value if found.
-| @param	Table: The table to search in.
-| @param	Needle: The value to search for.
-| @param	IsRecursive (Optional): Determines whether the search should be recursive.
-| @return	The value of the needle if found, or nil if not found (for arrays, this function will use standard Tables.find function).]]
function Tables.SearchForNeedle(Table: table, Needle: any, IsRecursive: boolean?): any?
	assert(type(Table) == "table", "Invalid Argument [1]; Table expected.")
	assert(Needle ~= nil, "Invalid Argument [2]; Received a nil argument.")
	-----------------------------------------------------------------------|

	if Tables.IsArray(Table) and not IsRecursive then
		return table.find(Table, Needle)
	else
		for Index, Value in pairs(Table) do
			if Index == Needle then
				return Value
			elseif IsRecursive and type(Value) == "table" then
				local RS = Tables.SearchForNeedle(Value, Needle, IsRecursive)
				if RS then return RS end
			end
		end
	end
	return nil
end

--[[ SearchAndReplace - Searches for the given needle in the given table and replaces it with the given replacement value.
-| @param	Table: The table to search in.
-| @param	Needle: The value to search for.
-| @param	Replacement (Optional): value to replace the needle with (if not provided, it will be removed, in other words, set to nil).
-| @param	IsRecursive (Optional): Determines whether the search should be recursive (Replacing any found needl).
-| @return	table, number - The modified table and the number of replacements made.]]
function Tables.SearchAndReplace(Table: table, Needle: any, Replacement: any?, IsRecursive: boolean?): (table, number)
	assert(type(Table) == "table", "Invalid Argument [1]; Table expected.")
	assert(Needle ~= nil, "Invalid Argument [2]; Received a nil argument.")
	----------------------------------------------------------------------|

	local Replacements = 0
	for Index, Value in pairs(Table) do
		if type(Value) ~= "table" and Index == Needle then
			Table[Index] = Replacement
			Replacements += 1
			if not IsRecursive then break end
		elseif IsRecursive and type(Value) == "table" then
			local Found, SubReplacements = Tables.SearchAndReplace(Value, Needle, Replacement, true)
			Replacements += SubReplacements
			if Found then Table[Index] = Found end
			if not IsRecursive then break end
		end
	end
	return Table, Replacements
end

--[[ DeconstructValueObjects - Deconstructs the given ancestor object and its children into a Tables.
-| @param	Ancestor: The ancestor object to be deconstructed.
-| @return	table - The resulting Tables.]]
function Tables.DeconstructValueObjects(Ancestor: Instance): (table)
	assert(typeof(Ancestor) == "Instance", "Invalid Argument [1]; Instance expected.")
	---------------------------------------------------------------------------------|

	local ToReturn = {}
	for _, Inst: Instance in ipairs(Ancestor:GetChildren()) do
		if Inst:IsA("Folder") or Inst:IsA("Configuration") then
			ToReturn[Inst.Name] = Tables.DeconstructValueObjects(Inst)
		elseif Inst:IsA("ValueBase") then
			ToReturn[Inst.Name] = (Inst :: ValueBase & {Value: any}).Value
		end
	end
	return ToReturn
end

--[[ TableToValueObjects - Converts the given table into a hierarchy of value objects and returns the root object.
-| @param	Table: The table to be converted.
-| @param	RootObject (Optional): The class name or instance to be used as the root object. If not provided, a folder will be used.
-| @param	Parent (Optional): The parent object for the root object. If not provided, the root object's parent will be set to itself.
-| @param	DefaultGroupingObject (Optional): The class name to be used for grouping objects. If not provided, "Folder" will be used.
-| @param	Processed (Optional): A table containing the already processed tables to prevent circular references.
-| @return	Instance - The root object of the hierarchy of value objects.]]
function Tables.ToValueObjects(Table: table, RootObject: (string | Instance)?, Parent: Instance?, DefaultGroupingObject: string?, Processed: table?): (Instance)
	assert(type(Table) == "table", "Invalid Argument [1]; Table expected.")
	assert(type(RootObject) == "string" or typeof(RootObject) == "Instance" or RootObject == nil, "Invalid Argument [2]; ClassName or Instance expected.")
	assert(typeof(Parent) == "Instance" or Parent == nil, "Error: Argument [3] must be an instance, but received an invalid type.")
	assert(typeof(DefaultGroupingObject) == "string" or DefaultGroupingObject == nil, "Error: Argument [4] must be a string, but received an invalid type.")
	-------------------------------------------------------------------------------------------------------------------------------------------------------|

	if Processed and Processed[Table] then
		return nil::any
	end

	local ToReturn
	local DGroupingClassName = DefaultGroupingObject or "Folder"
	local Processed: table = (Processed or {})

	if typeof(RootObject) == "Instance" then
		ToReturn = RootObject
	elseif type(RootObject) == "string" then
		local Success, Obj = pcall(function() return Instance.new(RootObject) end)
		if Success then ToReturn = Obj else ToReturn = Instance.new("Folder") end
	else
		ToReturn = Instance.new("Folder")
	end

	local ObjectsMapping = {
		["Ray"] = "RayValue",
		["integer"] = "IntValue",
		["boolean"] = "BoolValue",
		["number"] = "NumberValue",
		["string"] = "StringValue",
		["Color3"] = "Color3Value",
		["CFrame"] = "CFrameValue",
		["Instance"] = "ObjectValue",
		["Vector3"] = "Vector3Value",
		["BrickColor"] = "BrickColorValue",
	}

	Processed[Table] = true
	for Key, Value in pairs(Table) do
		local ValueType = typeof(Value)
		local Name = tostring(Key)
		if ValueType ~= "table" then
			local Obj = Instance.new(ObjectsMapping[ValueType])
			Obj.Name = Name
			Obj.Value = Value
			Obj.Parent = ToReturn
		elseif ValueType == "table" then
			local Children = Tables.ToValueObjects(Value, DGroupingClassName, ToReturn, DGroupingClassName, Processed)
			if Children then Children.Name = Name end
		end
	end
	ToReturn.Parent = (Parent or ToReturn.Parent)
	return ToReturn
end

--[[ Equals - Compares two tables to see if they are equal (Recursively if required).
-| @param	Table_1: The first table to compare.
-| @param	Table_2: The second table to compare.
-| @param	Recursive: Whether or not to recursively compare tables within the tables.
-| @param	UseMetamethodEquality: Whether or not to use the __eq metamethod to compare tables (other comparison methods are ignored).
-| @param	Cache: A cache table to prevent infinite loops caused by cyclical references (used by the function itself).
-| @return True if the tables are equal, false if they are not.]]
function Tables.Equals(Table_1: table, Table_2: table, Recursive: boolean?, UseMetamethodEquality: boolean?, Cache: table?): boolean
	assert(type(Table_1) == "table", "Error: Argument [1] must be a table, but received an invalid type.")
	assert(type(Table_2) == "table", "Error: Argument [2] must be a table, but received an invalid type.")
	-----------------------------------------------------------------------------------------------------|

	--| Early exit statements:
	if rawequal(Table_1, Table_2) then return true end	--| Checking if the tables are the same table (i.e., stored in the same memory location)
	if #Table_1 ~= #Table_2 then return false end		--| Tables are not equal if they have different lengths.
	if next(Table_1) == nil and next(Table_2) == nil then return true end	--| Checking if the tables are both empty.
	if UseMetamethodEquality then
		local MT1 = getmetatable(Table_1::any)
		local MT2 = getmetatable(Table_2::any)
		if MT1 and MT2 and MT1.__eq and MT2.__eq then
			return Table_1 == Table_2
		end
	end

	--| Cache is used to prevent infinit recursion. Ignored if there is no recursion.
	local Cache = (Cache ~=  nil and Cache) or (Recursive and {})::any
	if Recursive then
		if Cache[Table_1] and Cache[Table_2] then
			return true
		end
		Cache[Table_1] = true
		Cache[Table_2] = true
	end

	--| Comparing Table_1 to Table_2:
	for Key, Value in pairs(Table_1) do
		if type(Value) ~= "table" then
			if Table_2[Key] == nil or Table_2[Key] ~= Value then
				return false
			end
		else
			if not Recursive then continue end
			if type(Table_2[Key]) ~= "table" then return false end
			if Cache[Value] and Cache[Table_2[Key]] then return true end
			if not Tables.Equals(Value, Table_2[Key], true, UseMetamethodEquality, Cache) then return false end
		end
	end

	--| Comparing Table_2 to Table_1:
	for Key, Value in pairs(Table_2) do
		if type(Value) ~= "table" then
			if Table_1[Key] == nil or Table_1[Key] ~= Value then
				return false
			end
		else
			if not Recursive then continue end
			if type(Table_1[Key]) ~= "table" then return false end
			if Cache[Value] and Cache[Table_1[Key]] then return true end
			if not Tables.Equals(Value, Table_1[Key], true, UseMetamethodEquality, Cache) then return false end
		end
	end
	return true
end


----------------------------------------------------------------------|
--| Extended:
-------------
--| Extended libraries integrating (Name Format: "[Extended] - <name>").
for _, Library in ipairs(script:GetChildren()) do
	local Match = string.match(Library.Name, "%[Extended%]%s%-%s(.+)")
	if Library:IsA("ModuleScript") and Match then
		local Lib = require(Library)::any
		if IncludeSubLibraryFunctions then
			if type(Lib) == "function" then
				Tables[Match] = Lib
			else
				for name, func in pairs(Lib) do
					Tables[name] = func
				end
			end
		else
			Tables[Match] = Lib
		end
	end
end

--| Rename function names to be lowercased if desired.
if LowerCaseFunctionNames then
	local Temp = {}
	local SolveIndexing = function(t, k)
		return (rawget(t, k:lower())) or nil
	end
	for n, f in pairs(Tables) do
		Temp[n:lower()] = f
		Tables[n] = nil
		if type(f) == "table" then
			local TT = {}
			for nn, ff in pairs(f) do
				TT[nn:lower()] = ff
				f[nn] = nil
			end
			Temp[n:lower()] = TT
		end
	end
	Tables = setmetatable(Temp, {__index = SolveIndexing})::any
end

--| Integrates the standard string library functions into the module.
if MockupStandardLibrary then
	for Name, Func in pairs(table) do
		if not LowerCaseFunctionNames then
			Name = string.sub(Name, 1, 1) .. string.sub(Name, 2)
			if Name == "Foreachi" then
				Name = "ForEachI"
			elseif Name == "Foreach" then
				Name = "ForEach"
			elseif Name == "Isfrozen" then
				Name = "IsFrozen"
			end
		end
		Tables[Name] = Func
	end
end

-------------------------------------------
return Tables :: TypeChecking.TablesLowered
