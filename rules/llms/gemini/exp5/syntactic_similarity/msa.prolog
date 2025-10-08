%--------------- communication gap -----------%

initiatedAt(gap(Vessel)=near_port, T) :-
    happensAt(gap_start(Vessel), T),
    holdsAt(withinArea(Vessel, nearPorts)=true, T).

initiatedAt(gap(Vessel)=far_from_port, T) :-
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
    holdsAt(withinArea(Vessel, coastal)=true, T),
    \+ holdsAt(highSpeedNearCoast(Vessel)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax,
    holdsAt(highSpeedNearCoast(Vessel)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, coastal)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchored_far(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, IStopped),
    holdsFor(withinArea(Vessel, anchorage)=true, IArea),
    intersect_all([IStopped, IArea], I).

holdsFor(anchoredOrMoored_candidate(Vessel)=true, I) :-
    holdsFor(anchored_far(Vessel)=true, IAnchoredFar),
    holdsFor(stopped(Vessel)=nearPorts, IMooredNear),
    union_all([IAnchoredFar, IMooredNear], I).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(anchoredOrMoored_candidate(Vessel)=true, ICandidate),
    intDurGreater(ICandidate, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax,
    \+ holdsAt(tuggingSpeed(Vessel)=true, T).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMin, TuggingMin),
    Speed < TuggingMin,
    holdsAt(tuggingSpeed(Vessel)=true, T).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax,
    holdsAt(tuggingSpeed(Vessel)=true, T).

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging_candidate(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, IProx),
    holdsFor(tuggingSpeed(Vessel1)=true, ISpeed1),
    holdsFor(tuggingSpeed(Vessel2)=true, ISpeed2),
    oneIsTug(Vessel1, Vessel2),
    vesselType(Vessel1, T1), T1 \== pilot,
    vesselType(Vessel2, T2), T2 \== pilot,
    intersect_all([IProx, ISpeed1, ISpeed2], I).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(tugging_candidate(Vessel1, Vessel2)=true, ICandidate),
    intDurGreater(ICandidate, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed >= TrawlingspeedMin,
    Speed =< TrawlingspeedMax,
    holdsAt(withinArea(Vessel, fishing)=true, T),
    \+ holdsAt(trawlingSpeed(Vessel)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMin, TrawlingspeedMin),
    Speed < TrawlingspeedMin,
    holdsAt(trawlingSpeed(Vessel)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(trawlingspeedMax, TrawlingspeedMax),
    Speed > TrawlingspeedMax,
    holdsAt(trawlingSpeed(Vessel)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishing)=true, T).

terminatedAt(trawlingMovement(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishing)=true), T).

holdsFor(trawling_candidate(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, ISpeed),
    holdsFor(trawlingMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], I).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawling_candidate(Vessel)=true, ICandidate),
    intDurGreater(ICandidate, trawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed,
    \+ holdsAt(sarSpeed(Vessel)=true, T).

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _, _), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed,
    holdsAt(sarSpeed(Vessel)=true, T).

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarMovement(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(sar_candidate(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, ISpeed),
    holdsFor(sarMovement(Vessel)=true, IMovement),
    intersect_all([ISpeed, IMovement], I).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sar_candidate(Vessel)=true, ICandidate),
    intDurGreater(ICandidate, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering_base_state(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, ILowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, IStoppedFar),
    union_all([ILowSpeed, IStoppedFar], I).

holdsFor(loitering_candidate(Vessel)=true, I) :-
    holdsFor(loitering_base_state(Vessel)=true, IBase),
    holdsFor(withinArea(Vessel, coastal)=true, ICoastal),
    holdsFor(anchoredOrMoored(Vessel)=true, IAnchored),
    relative_complement_all(IBase, [ICoastal, IAnchored], I).

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(loitering_candidate(Vessel)=true, ICandidate),
    intDurGreater(ICandidate, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotSpeedOrStopped(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, ILowSpeed),
    holdsFor(stopped(Vessel)=farFromPorts, IStoppedFar),
    union_all([ILowSpeed, IStoppedFar], I).

holdsFor(pilotOps_candidate(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, IProx),
    holdsFor(pilotSpeedOrStopped(Vessel1)=true, ISpeed1),
    holdsFor(pilotSpeedOrStopped(Vessel2)=true, ISpeed2),
    oneIsPilot(Vessel1, Vessel2),
    intersect_all([IProx, ISpeed1, ISpeed2], I).

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(pilotOps_candidate(Vessel1, Vessel2)=true, ICandidate),
    holdsFor(withinArea(Vessel1, coastal)=true, ICoastal1),
    holdsFor(withinArea(Vessel2, coastal)=true, ICoastal2),
    relative_complement_all(ICandidate, [ICoastal1, ICoastal2], I).