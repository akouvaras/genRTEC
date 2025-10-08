%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=nearPorts, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=farFromPorts, T) :-
    happensAt(gap_start(Vessel), T),
    not holdsAt(withinArea(Vessel, nearPorts)=true, T).

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
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed > MaxSpeed,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, MaxSpeed),
    Speed =< MaxSpeed,
    holdsAt(highSpeedNearCoast(Vessel)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, nearCoast).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status, I_stop),
    holdsFor(withinArea(Vessel, nearPorts)=true, I_near),
    holdsFor(withinArea(Vessel, Type)=true, I_anc_temp),
    anchorageAreaType(Type),
    I_anc = I_anc_temp,
    union_all([I_near, I_anc], I_loc),
    intersect_all([I_stop, I_loc], I_candidate),
    I_candidate \= [],
    thresholds(aOrMTime, MinDuration),
    intDurGreater(I_candidate, MinDuration, I).

%--------------- tugging (B) ----------------%

initiatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed >= Min,
    Speed =< Max,
    not holdsAt(hasTuggingSpeed(Vessel)=true, T).

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    (Speed < Min ; Speed > Max),
    holdsAt(hasTuggingSpeed(Vessel)=true, T).

terminatedAt(hasTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(hasTuggingSpeed(Vessel1)=true, I1),
    holdsFor(hasTuggingSpeed(Vessel2)=true, I2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    intersect_all([I1, I2, Ip], I_inter),
    I_inter \= [],  % non-empty intersection
    thresholds(tuggingTime, MinDuration),
    intDurGreater(I_inter, MinDuration, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed >= Min,
    Speed =< Max,
    holdsAt(withinFishingArea(Vessel)=true, T),
    not holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed < Min,
    holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed > Max,
    holdsAt(hasTrawlingSpeed(Vessel)=true, T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, Type),
    fishingAreaType(Type).

%--------------- trawling --------------------%

initiatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinFishingArea(Vessel)=true, T).

terminatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, Type),
    fishingAreaType(Type).

terminatedAt(movementTrawling(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(movementTrawling(Vessel)=true, I2),
    intersect_all([I1, I2], I_inter),
    I_inter \= [],  % non-empty
    thresholds(trawlingTime, MinDuration),
    intDurGreater(I_inter, MinDuration, I).

%-------------------------- SAR --------------%

initiatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, Min),
    Speed >= Min,
    not holdsAt(hasSARSpeed(Vessel)=true, T).

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, Min),
    Speed < Min,
    holdsAt(hasSARSpeed(Vessel)=true, T).

terminatedAt(hasSARSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    not holdsAt(movementSAR(Vessel)=true, T).

initiatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    not holdsAt(movementSAR(Vessel)=true, T).

terminatedAt(movementSAR(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(hasSARSpeed(Vessel)=true, I1),
    holdsFor(movementSAR(Vessel)=true, I2),
    intersect_all([I1, I2], I_inter),
    I_inter \= [],  % non-empty overlap
    thresholds(sarOperationTime, MinDuration),
    intDurGreater(I_inter, MinDuration, I).

%-------- loitering --------------------------%

holdsFor(inLoiterMotion(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    union_all([I1, I2], I).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(inLoiterMotion(Vessel)=true, I_motion),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_coast),
    relative_complement_all(I_motion, [I_coast], I_no_coast),
    holdsFor(anchoredOrMoored(Vessel)=true, I_orm),
    relative_complement_all(I_no_coast, [I_orm], I_candidate),
    I_candidate \= [],  % ensure some interval remains
    thresholds(loiteringTime, MinDuration),
    intDurGreater(I_candidate, MinDuration, I).

%-------- pilotOps ---------------------------%

holdsFor(inLowMotion(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, I1),
    holdsFor(stopped(Vessel)=farFromPorts, I2),
    union_all([I1, I2], I).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(inLowMotion(Vessel1)=true, I1),
    holdsFor(inLowMotion(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], I_candidate),
    I_candidate \= [],  % non-empty
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(I_candidate, [Ic1, Ic2], I).