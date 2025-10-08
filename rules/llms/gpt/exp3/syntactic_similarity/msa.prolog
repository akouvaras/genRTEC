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
    happensAt(start(gap(Vessel)=_GapStatus), T).

%------------ highSpeedNearCoast -------------%

initiatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, HcMax),
    Speed > HcMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, HcMax),
    Speed =< HcMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(stopped(Vessel)=farFromPorts, IsFar),
    holdsFor(withinArea(Vessel, anchorageArea)=true, Ia),
    intersect_all([IsFar, Ia], I_farAnch),
    holdsFor(stopped(Vessel)=nearPorts, Inp),
    union_all([I_farAnch, Inp], Icand),
    intDurGreater(Icand, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed >= TuggingMin,
    Speed =< TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed < TuggingMin.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TuggingMin),
    thresholds(tuggingMax, TuggingMax),
    Speed > TuggingMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    Vessel1 \= Vessel2,
    oneIsTug(Vessel1, Vessel2),
    not oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(tuggingSpeed(Vessel1)=true, I1),
    holdsFor(tuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], Ii),
    intDurGreater(Ii, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlMin),
    thresholds(trawlingspeedMax, TrawlMax),
    Speed >= TrawlMin,
    Speed =< TrawlMax,
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlMin),
    thresholds(trawlingspeedMax, TrawlMax),
    Speed < TrawlMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlMin),
    thresholds(trawlingspeedMax, TrawlMax),
    Speed > TrawlMax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawlingSpeed(Vessel)=true, Is),
    holdsFor(trawlingPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], Ii),
    intDurGreater(Ii, trawlingTime, I).

%-------------------------- SAR --------------%

initiatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed >= SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(sarMinSpeed, SarMinSpeed),
    Speed < SarMinSpeed.

terminatedAt(sarSpeed(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(start(gap(Vessel)=_GapStatus), T).

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(sarSpeed(Vessel)=true, Is),
    holdsFor(sarPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], Ii),
    intDurGreater(Ii, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Ilow),
    holdsFor(stopped(Vessel)=farFromPorts, Ifar),
    union_all([Ilow, Ifar], Imotion),
    holdsFor(withinArea(Vessel, nearCoast)=true, Icoast),
    relative_complement_all(Imotion, [Icoast], Inocoast),
    holdsFor(anchoredOrMoored(Vessel)=true, Iaom),
    relative_complement_all(Inocoast, [Iaom], Icand),
    intDurGreater(Icand, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    Vessel1 \= Vessel2,
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    union_all([Il1, Is1], I1b),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If), If \= [],
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    relative_complement_all(If, [Iw1, Iw2], I).