%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    \+ holdsAt(withinArea(Vessel, nearPorts)=true, T).

terminatedAt(gap(Vessel)=_Status, T) :-
    happensAt(gap_end(Vessel), T).

%-------------- lowspeed----------------------%

initiatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_start(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(slow_motion_end(Vessel), T).

terminatedAt(lowSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, nearCoast)=true, T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=nearPorts, IStoppedNear),
    holdsFor(stopped(Vessel)=farFromPorts, IStoppedFar),
    union_all([IStoppedNear, IStoppedFar], IStoppedTotal),
    holdsFor(withinArea(Vessel, anchorage)=true, IAnchorage),
    intersect_all([IStoppedTotal, IAnchorage], IIntermediate),
    thresholds(aOrMTime, AOrMTime),
    intDurGreater(IIntermediate, AOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    \+ oneIsPilot(Vessel1, Vessel2),
    holdsFor(hasTuggingSpeed(Vessel1)=true, ISpeed1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, ISpeed2),
    holdsFor(proximity(Vessel1, Vessel2)=true, IProx),
    intersect_all([ISpeed1, ISpeed2, IProx], IIntermediate),
    thresholds(tuggingTime, TuggingTime),
    intDurGreater(IIntermediate, TuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

%--------------- trawling --------------------%

initiatedAt(hasTrawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(hasTrawlingMovement(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, ISpeed),
    holdsFor(hasTrawlingMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntermediate),
    thresholds(trawlingTime, TrawlingTime),
    intDurGreater(IIntermediate, TrawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(hasSarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(hasSarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(hasSarSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

initiatedAt(hasSarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(hasSarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(hasSarMovement(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSarSpeed(Vessel)=true, ISpeed),
    holdsFor(hasSarMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntermediate),
    thresholds(sarTime, SarTime),
    intDurGreater(IIntermediate, SarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, ILowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, IStopped),
    union_all([ILowSpeed, IStopped], IBase),
    holdsFor(withinArea(Vessel, nearCoast)=true, ICoast),
    holdsFor(anchoredOrMoored(Vessel)=true, IAnchored),
    relative_complement_all(IBase, [ICoast, IAnchored], IIntermediate),
    thresholds(loiteringTime, LoiteringTime),
    intDurGreater(IIntermediate, LoiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, ILowSpeed1),
    holdsFor(stopped(Vessel1)=farFromPorts, IStopped1),
    union_all([ILowSpeed1, IStopped1], IState1),
    holdsFor(lowSpeed(Vessel2)=true, ILowSpeed2),
    holdsFor(stopped(Vessel2)=farFromPorts, IStopped2),
    union_all([ILowSpeed2, IStopped2], IState2),
    holdsFor(proximity(Vessel1, Vessel2)=true, IProximity),
    intersect_all([IState1, IState2, IProximity], IIntermediate),
    holdsFor(withinArea(Vessel1, nearCoast)=true, ICoast1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, ICoast2),
    relative_complement_all(IIntermediate, [ICoast1, ICoast2], I).