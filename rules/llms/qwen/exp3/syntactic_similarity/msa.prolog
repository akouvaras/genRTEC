%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPort, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, AreaType)=true, T),
    areaType(_, AreaType),
    member(AreaType, [port, anchorage]).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not (holdsAt(withinArea(Vessel, AreaType)=true, T),
         areaType(_, AreaType),
         member(AreaType, [port, anchorage])).

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
    holdsAt(withinArea(Vessel, coastal)=true, T),
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed > MaxSpeed.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(highSpeedNearCoast(Vessel)=true, T),  
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed =< MaxSpeed.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, coastal),
    holdsAt(highSpeedNearCoast(Vessel)=true, T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status1, I_stop),
    holdsFor(withinArea(Vessel, anchorage)=true, I_anchorage),
    intersect_all([I_stop, I_anchorage], I_case1),
    holdsFor(stopped(Vessel)=nearPorts, I_case2),
    union_all([I_case1, I_case2], I_temp), I_temp \= [],
    thresholds(aOrMTime, MinDuration),
    intDurGreater(I_temp, MinDuration, I).

%--------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    Speed >= MinSpeed,
    Speed =< MaxSpeed.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    Speed < MinSpeed.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTuggingSpeed(Vessel)=true, T),
    thresholds(tuggingMin, MinSpeed),
    thresholds(tuggingMax, MaxSpeed),
    Speed > MaxSpeed.

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(hasTuggingSpeed(Vessel1)=true, I1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], I_temp), I_temp \= [],
    thresholds(tuggingTime, MinDuration),
    intDurGreater(I_temp, MinDuration, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    thresholds(trawlingspeedMin, MinSpeed),
    thresholds(trawlingspeedMax, MaxSpeed),
    Speed >= MinSpeed,
    Speed =< MaxSpeed.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    thresholds(trawlingspeedMin, MinSpeed),
    thresholds(trawlingspeedMax, MaxSpeed),
    Speed < MinSpeed.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasTrawlingSpeed(Vessel)=true, T),
    thresholds(trawlingspeedMin, MinSpeed),
    thresholds(trawlingspeedMax, MaxSpeed),
    Speed > MaxSpeed.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).

%--------------- trawling --------------------%

initiatedAt(movementCharacteristicOfTrawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(movementCharacteristicOfTrawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, AreaID), T),
    areaType(AreaID, fishing).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(movementCharacteristicOfTrawling(Vessel)=true, I2),
    intersect_all([I1, I2], I_temp), I_temp \= [],
    thresholds(trawlingTime, MinDuration),
    intDurGreater(I_temp, MinDuration, I).

%-------------------------- SAR --------------%

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, MinSpeed),
    Speed >= MinSpeed.

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    holdsAt(hasSARSpeed(Vessel)=true, T),
    thresholds(sarMinSpeed, MinSpeed),
    Speed < MinSpeed.

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(movementCharacteristicOfSAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(movementCharacteristicOfSAR(Vessel)=true, I2),
    intersect_all([I1, I2], I_temp), I_temp \= [],
    thresholds(sarTime, MinDuration),
    intDurGreater(I_temp, MinDuration, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], I_motion),
    holdsFor(withinArea(Vessel, coastal)=true, I_coast),
    relative_complement_all(I_motion, [I_coast], I_not_coast), I_not_coast \= [],
    holdsFor(anchoredOrMoored(Vessel)=true, I_anchored),
    relative_complement_all(I_not_coast, [I_anchored], I_candidate), I_candidate \= [],
    thresholds(loiteringTime, MinDuration),
    intDurGreater(I_candidate, MinDuration, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I1_combined),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I2_combined),
    intersect_all([I1_combined, I2_combined, Ip], I_motion), I_motion \= [],
    holdsFor(withinArea(Vessel1, coastal)=true, Ic1),
    holdsFor(withinArea(Vessel2, coastal)=true, Ic2),
    relative_complement_all(I_motion, [Ic1, Ic2], I).