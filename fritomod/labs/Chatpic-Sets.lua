-- A few sets that we use in Chatpic. A set is a table that maps characters to their
-- translation. Chatpic and Strings.Transform can use sets.

if nil ~= require then
	require "fritomod/labs/Chatpic";
end;

local sets=Chatpic.sets;

sets.legacy={
	["_"] = "{square}",
	["0"] = "{skull}",
	["1"] = "{x}",
	["2"] = "{circle}",
	["3"] = "{triangle}",
	["4"] = "{diamond}",
	["5"] = "{star}",
	["6"] = "{moon}",
};

sets.marks=Metatables.CoercingKey({}, string.lower);
sets.raidmarks=sets.marks;
sets.rm=sets.marks;
sets.mark=sets.marks;

do
	local square="{square}";
	sets.marks["q"]=square;
	sets.marks["_"]=square;
	sets.marks["#"]=square;
	sets.marks["["]=square;
	sets.marks["]"]=square;

	local skull="{skull}";
	sets.marks["k"]=skull;
	sets.marks[":"]=skull;
	sets.marks["8"]=skull;
	sets.marks["$"]=skull;
	sets.marks["\""]=skull;

	local x="{x}";
	sets.marks["x"]=x;

	local circle="{circle}";
	sets.marks["0"]=circle;
	sets.marks["o"]=circle;
	sets.marks["@"]=circle;
	sets.marks["c"]=circle;

	local triangle="{triangle}";
	sets.marks["t"]=triangle;
	sets.marks["<"]=triangle;
	sets.marks[">"]=triangle;
	sets.marks["^"]=triangle;
	sets.marks["%"]=triangle;
	sets.marks["v"]=triangle;
	sets.marks["w"]=triangle;

	local diamond="{diamond}";
	sets.marks["d"]=diamond;
	sets.marks["a"]=diamond;
	sets.marks["|"]=diamond;
	sets.marks["\\"]=diamond;
	sets.marks["/"]=diamond;
	sets.marks["!"]=diamond;
	sets.marks["1"]=diamond;

	local star="{star}";
	sets.marks["s"]=star;
	sets.marks["*"]=star;
	sets.marks["."]=star;
	sets.marks["'"]=star;
	sets.marks["+"]=diamond;

	local moon="{moon}";
	sets.marks["m"]=moon;
	sets.marks["n"]=moon;
	sets.marks["("]=moon;
	sets.marks[")"]=moon;
	sets.marks["{"]=moon;
	sets.marks["}"]=moon;
end;

sets.blocks={
	["_"] = 75,
	["0"] = 72
};
sets.block=sets.blocks;
sets.uchar=sets.blocks;
sets.unicode=sets.blocks;

