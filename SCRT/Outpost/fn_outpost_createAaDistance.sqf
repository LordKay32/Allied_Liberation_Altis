if (!isServer and hasInterface) exitWith {};

private _markerX = _this select 0;
private _positionX = getMarkerPos _markerX;
private _garrison = garrison getVariable [_markerX, []];
private _statics = garrison getVariable [(_markerX + "_statics"), []];

private _props = [];
private _weaps = [];

if (isNil "_garrison") then {
    _garrison = [UKSL,UKMG,UKATman,UKMedic,UKMil,UKMil,UKMil,UKMil];
    garrison setVariable [_markerX,_garrison,true];
};

private _groupX = [_positionX, teamPlayer, _garrison,true,false] call A3A_fnc_spawnGroup;
private _groupXUnits = units _groupX;
_groupXUnits apply { [_x,_markerX] spawn A3A_fnc_FIAinitBases; if ((_x getVariable "unitType") in squadLeaders) then {_x linkItem "ItemRadio"} };

private _staticPositionInfo = staticPositions getVariable [_markerX, []];
private _staticPosition = _staticPositionInfo select 0;
private _staticDirection = _staticPositionInfo select 1;
private _posRight = [_staticPosition, 8, (_staticDirection + 90)] call BIS_Fnc_relPos;
{
    private _relativePosition = [_posRight, 4, (_staticDirection + _x)] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _posRight] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [45, 135, 225, 315];

private _groupAAUnits = _groupXUnits;

if (count _statics > 0) then {
	private _veh = objNull;
	_veh = createVehicle [staticAAteamPlayer, _posRight, [], 0, "CAN_COLLIDE"];
	_veh setDir _staticDirection;
	_veh addEventHandler ["Killed", {
		_markerX = [aapostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		if (count _statics == 2) then {_statics deleteAt 1} else {_statics deleteAt 0};
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh;

	sleep 1;

	[_veh,"Move_Outpost_Static"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _veh];

	private _crewManIndex = _groupAAUnits findIf {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
	    private _crewMan = _groupAAUnits select _crewManIndex;
	    _crewMan moveInGunner _veh;
	    [_crewMan, 300] spawn SCRT_fnc_common_scanHorizon;
	    _groupAAUnits deleteAT _crewManIndex;
	};
	_crewManIndex = _groupAAUnits findIf {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	_crewMan = _groupAAUnits select _crewManIndex;
    	_crewMan moveInAny _veh;
    	_groupAAUnits deleteAT _crewManIndex;
	};
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
};

private _posLeft = [_staticPosition, 8, (_staticDirection + 270)] call BIS_Fnc_relPos;
{
    private _relativePosition = [_posLeft, 4, (_staticDirection + _x)] call BIS_Fnc_relPos;
    private _sandbag = createVehicle ["Land_BagFence_Round_F", _relativePosition, [], 0, "CAN_COLLIDE"];
    _sandbag setDir ([_sandbag, _posLeft] call BIS_fnc_dirTo);
    _sandbag setVectorUp surfaceNormal position _sandbag;
    _props pushBack _sandbag;
} forEach [45, 135, 225, 315];

if (count _statics > 1) then {
	private _veh = objNull;
	_veh = createVehicle [staticAAteamPlayer, _posLeft, [], 0, "CAN_COLLIDE"];
	_veh setDir _staticDirection;
	_veh addEventHandler ["Killed", {
		_markerX = [aapostsFIA, _unit] call BIS_fnc_nearestPosition;
		_statics = garrison getVariable [(_markerX + "_statics"), []];
		if (count _statics == 2) then {_statics deleteAt 1} else {_statics deleteAt 0};
		garrison setVariable [(_markerX + "_statics"),_statics,true];
	}];
	_weaps pushBack _veh;

	sleep 1;

	[_veh,"Move_Outpost_Static"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian], _veh];

	_crewManIndex = _groupAAUnits findIf {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	_crewMan = _groupAAUnits select _crewManIndex;
    	_crewMan moveInGunner _veh;
    	[_crewMan, 300] spawn SCRT_fnc_common_scanHorizon;
    	_groupAAUnits deleteAT _crewManIndex;
	};
	_crewManIndex = _groupAAUnits findIf {(_x getVariable "unitType") == UKMil};
	if (_crewManIndex != -1) then {
    	_crewMan = _groupAAUnits select _crewManIndex;
    	_crewMan moveInAny _veh;
	};
	[_veh, teamPlayer] call A3A_fnc_AIVEHinit;
};

_groupX setBehaviour "SAFE";
_groupX setCombatMode "YELLOW"; 
_groupX setFormation "FILE";
private _wp0 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 45)] call BIS_Fnc_relPos, 0];
private _wp1 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 135)] call BIS_Fnc_relPos, 0];
private _wp2 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 225)] call BIS_Fnc_relPos, 0];
private _wp3 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 315)] call BIS_Fnc_relPos, 0];
private _wp4 = _groupX addWaypoint [[_staticPosition, 60, (_staticDirection + 45)] call BIS_Fnc_relPos, 0];
_wp4 setWaypointType "CYCLE";

waitUntil {
	sleep 1; 
	((spawner getVariable _markerX == 2)) or 
	({alive _x} count units _groupX == 0) or (!(_markerX in aapostsFIA))
};

if ({alive _x} count units _groupX == 0) then {
	aapostsFIA = aapostsFIA - [_markerX]; publicVariable "aapostsFIA";
	markersX = markersX - [_markerX]; publicVariable "markersX";
	sidesX setVariable [_markerX,nil,true];
	_nul = [5,-5,_positionX] remoteExec ["A3A_fnc_citySupportChange",2];
	deleteMarker _markerX;
	["TaskFailed", ["", "AA Emplacement Lost"]] remoteExec ["BIS_fnc_showNotification", 0];
};

waitUntil {sleep 1; (spawner getVariable _markerX == 2) or (!(_markerX in aapostsFIA))};

{
	deleteVehicle _x;
} forEach _weaps;

{ 
    deleteVehicle _x 
} forEach units _groupX;
deleteGroup _groupX;

{
	deleteVehicle _x;
} forEach _props;