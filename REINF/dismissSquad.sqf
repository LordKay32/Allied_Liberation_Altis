//if (!isServer) exitWith{};
private ["_groups","_hr","_resourcesFIA","_wp","_groupX","_veh","_leave","_unitLoadout"];

_groups = _this select 0;
_hr = 0;
_resourcesFIA = 0;
_leave = false;

{
	if ((groupID _x) in ["MineF", "Watch"]
		|| { isPlayer (leader _x)
		|| { (units _x) findIf { _x == petros } != -1 }})
	exitWith { _leave = true; };
} forEach _groups;

if (_leave) exitWith {["Dismiss Squad", "You cannot dismiss player led, Watchpost, Roadblocks or Minefield building squads."] call A3A_fnc_customHint;};

{
if (_x getVariable ["esNATO",false]) then {_leave = true};
} forEach _groups;

if (_leave) exitWith {["Dismiss Squad", "You cannot dismiss NATO groups."] call A3A_fnc_customHint;};

_pos = getMarkerPos respawnTeamPlayer;

{
	theBoss sideChat format ["%2, I'm sending %1 back to base", _x,name petros];
	theBoss hcRemoveGroup _x;
	_wp = _x addWaypoint [_pos, 0];
	_wp setWaypointType "MOVE";
	sleep 3
} forEach _groups;

sleep 100;

private _assignedVehicles =	[];
private _unitTypes = [];
private _allLoadouts = []; //for JB code

{
	_groupX = _x;
	{
		if (alive _x) then
		{
			_hr = _hr + 1;
			teamPlayerStoodDown = teamPlayerStoodDown + 1;
			publicVariable "teamPlayerStoodDown";
			_resourcesFIA = _resourcesFIA + (server getVariable [_x getVariable "unitType",0]);
			_unitTypes pushBack (_x getVariable "unitType");
			if (!isNull (assignedVehicle _x) and {isNull attachedTo (assignedVehicle _x)}) then
			{
				_assignedVehicles pushBackUnique (assignedVehicle _x);
			};
		};
		_unitLoadout = getUnitLoadout _x;
		_allLoadouts pushBack _unitLoadout;
		deleteVehicle _x;
	} forEach units _groupX;
	deleteGroup _groupX;
} forEach _groups;

{
	private _veh = _x;
	if !(typeOf _veh in vehFIA) then { continue };
	_resourcesFIA = _resourcesFIA + ([typeOf _veh] call A3A_fnc_vehiclePrice);
	private _count = server getVariable ((typeOf _veh) + "_count");
    _count = _count + 1;
    server setVariable [((typeOf _veh) + "_count"), _count, true];
	{
		if !(typeOf _x in vehFIA) then { continue };
		_resourcesFIA = _resourcesFIA + ([typeOf _x] call A3A_fnc_vehiclePrice);
		private _count = server getVariable ((typeOf _x) + "_count");
    	_count = _count + 1;
    	server setVariable [((typeOf _x) + "_count"), _count, true];
		deleteVehicle _x;
	} forEach attachedObjects _veh;
	deleteVehicle _veh;
} forEach _assignedVehicles;

//JB code to return gear to arsenal

_fullSquadGear = _allLoadouts call A3A_fnc_reorgLoadoutSquad;
 	
	{ [_x select 0 call jn_fnc_arsenal_itemType, _x select 0, _x select 1]call jn_fnc_arsenal_addItem } forEach _fullSquadGear;

// JB code end

_nul = [_hr,_resourcesFIA,_unitTypes] remoteExec ["A3A_fnc_resourcesFIA",2];