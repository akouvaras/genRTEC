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
    happensAt(gap_start(Vessel), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=nearPorts, INear),
    holdsFor(stopped(Vessel)=farFromPorts, IFar),
    union_all([INear, IFar], IStopped),
    holdsFor(withinArea(Vessel, anchorage)=true, IAnchorage),
    intersect_all([IStopped, IAnchorage], IIntersected),
    intDurGreater(IIntersected, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, IProximity),
    holdsFor(tuggingSpeed(Vessel1)=true, ISpeed1),
    holdsFor(tuggingSpeed(Vessel2)=true, ISpeed2),
    intersect_all([IProximity, ISpeed1, ISpeed2], IIntersected),
    intDurGreater(IIntersected, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T),
    thresholds(trawlingspeedMin, TrawlingSpeedMin),
    thresholds(trawlingspeedMax, TrawlingSpeedMax),
    Speed >= TrawlingSpeedMin,
    Speed =< TrawlingSpeedMax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingSpeedMin),
    Speed < TrawlingSpeedMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMax, TrawlingSpeedMax),
    Speed > TrawlingSpeedMax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, ISpeed),
    holdsFor(trawlingMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntersected),
    intDurGreater(IIntersected, trawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_Status), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, ISpeed),
    holdsFor(sarMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], IIntersected),
    intDurGreater(IIntersected, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, ILowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, IStopped),
    union_all([ILowSpeed, IStopped], ICandidate),
    holdsFor(withinArea(Vessel, nearCoast)=true, ICoast),
    holdsFor(anchoredOrMoored(Vessel)=true, IAnchored),
    relative_complement_all(ICandidate, [ICoast, IAnchored], IFiltered),
    intDurGreater(IFiltered, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, IProximity),
    holdsFor(lowSpeed(Vessel1)=true, ILowSpeed1),
    holdsFor(stopped(Vessel1)=farFromPorts, IStopped1),
    union_all([ILowSpeed1, IStopped1], IMovement1),
    holdsFor(lowSpeed(Vessel2)=true, ILowSpeed2),
    holdsFor(stopped(Vessel2)=farFromPorts, IStopped2),
    union_all([ILowSpeed2, IStopped2], IMovement2),
    intersect_all([IProximity, IMovement1, IMovement2], ICandidate),
    holdsFor(withinArea(Vessel1, nearCoast)=true, ICoast1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, ICoast2),
    relative_complement_all(ICandidate, [ICoast1, ICoast2], I).