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

holdsFor(highSpeedNearCoast(Vessel)=true, I) :-
    holdsFor(withinArea(Vessel, nearCoast)=true, I1),
    holdsFor(excessiveSpeed(Vessel)=true, I2),
    intersect_all([I1, I2], I).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=_Status1, I1),
    holdsFor(withinArea(Vessel, nearPorts)=true, I2),
    intersect_all([I1, I2], I_nearPort),
    holdsFor(stopped(Vessel)=_Status2, I3),
    holdsFor(withinArea(Vessel, anchorage)=true, I4),
    holdsFor(withinArea(Vessel, nearPorts)=true, I5),
    relative_complement_all(I3, [I5], I_farFromPorts),  
    intersect_all([I3, I4, I_farFromPorts], I_inAnchorage),  
    union_all([I_nearPort, I_inAnchorage], I_unfiltered),
    thresholds(aOrMTime, MinDuration),
    intDurGreater(I_unfiltered, MinDuration, I).

%--------------- tugging (B) ----------------%

initiatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMin, Min),
    thresholds(tuggingMax, Max),
    Speed >= Min,
    Speed =< Max.

terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMin, Min), Speed < Min.

terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(tuggingMax, Max), Speed > Max.

terminatedAt(withinTuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    Vessel1 @< Vessel2,
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(withinTuggingSpeed(Vessel1)=true, I1),
    holdsFor(withinTuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], I_candidate),
    thresholds(tuggingTime, MinDuration),
    intDurGreater(I_candidate, MinDuration, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed >= Min,
    Speed =< Max.

initiatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(entersArea(Vessel, Area), T),
    areaType(Area, fishing),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, Min),
    thresholds(trawlingspeedMax, Max),
    Speed >= Min,
    Speed =< Max.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMin, Min), Speed < Min.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(trawlingspeedMax, Max), Speed > Max.

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(hasTrawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

%--------------- trawling --------------------%

initiatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(leavesArea(Vessel, Area), T),
    areaType(Area, fishing).

terminatedAt(characteristicTrawlingMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(hasTrawlingSpeed(Vessel)=true, I1),
    holdsFor(characteristicTrawlingMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I_unfiltered),
    thresholds(trawlingTime, MinDuration),
    intDurGreater(I_unfiltered, MinDuration, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(sarMinSpeed, Min),
    Speed >= Min.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(change_in_speed_end(Vessel), T),
    lastReportedSpeed(Vessel, T, Speed),
    thresholds(sarMinSpeed, Min),
    Speed < Min.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T),
    holdsAt(sarSpeed(Vessel)=true, T).

initiatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(sarSpeed(Vessel)=true, T).

terminatedAt(exhibitingSARMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, I1),
    holdsFor(exhibitingSARMovement(Vessel)=true, I2),
    intersect_all([I1, I2], I_candidate),
    thresholds(sarTime, MinDuration),
    intDurGreater(I_candidate, MinDuration, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], I_movement),
    holdsFor(withinArea(Vessel, nearCoast)=true, I_coast),
    relative_complement_all(I_movement, [I_coast], I_offCoast),
    I_offCoast \= [],
    holdsFor(anchoredOrMoored(Vessel)=true, I_aorm),
    relative_complement_all(I_offCoast, [I_aorm], I_unfiltered),
    thresholds(loiteringTime, MinDuration),
    intDurGreater(I_unfiltered, MinDuration, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    Vessel1 @< Vessel2,
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I_behave1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I_behave2),
    holdsFor(withinArea(Vessel1, nearPorts)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearPorts)=true, Iw2),
    holdsFor(withinArea(Vessel1, nearCoast)=true, Ic1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Ic2),
    relative_complement_all(Ip, [Iw1, Iw2, Ic1, Ic2], I_noGo),
    I_noGo \= [],  
    intersect_all([I_noGo, I_behave1, I_behave2], I_unfiltered),
    I = I_unfiltered.