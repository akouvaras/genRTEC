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
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed > HcNearCoastMax,
    holdsAt(withinArea(Vessel, nearCoast)=true, T).

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(hcNearCoastMax, HcNearCoastMax),
    Speed =< HcNearCoastMax.

terminatedAt(highSpeedNearCoast(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, nearCoast)=true), T).

%-------------- anchoredOrMoored ---------------%

holdsFor(aorm_far(Vessel)=true, Ifar) :-
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    holdsFor(withinArea(Vessel, anchorageArea)=true, Ia),
    intersect_all([Is, Ia], Ifar), Ifar \= [].

holdsFor(aorm_near(Vessel)=true, Inear) :-
    holdsFor(stopped(Vessel)=nearPorts, Inear).

holdsFor(anchoredOrMoored(Vessel)=true, I) :-
    holdsFor(aorm_far(Vessel)=true, Ifar),
    holdsFor(aorm_near(Vessel)=true, Inear),
    union_all([Ifar, Inear], Iu),
    intDurGreater(Iu, aOrMTime, I).

%--------------- tugging (B) ----------------%

initiatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TugMin),
    thresholds(tuggingMax, TugMax),
    Speed >= TugMin,
    Speed =< TugMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMin, TugMin),
    Speed < TugMin.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(tuggingMax, TugMax),
    Speed > TugMax.

terminatedAt(tuggingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(tugging_base(Vessel1, Vessel2)=true, If) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    not oneIsPilot(Vessel1, Vessel2),
    oneIsTug(Vessel1, Vessel2),
    holdsFor(tuggingSpeed(Vessel1)=true, I1),
    holdsFor(tuggingSpeed(Vessel2)=true, I2),
    intersect_all([Ip, I1, I2], If), If \= [].

holdsFor(tugging(Vessel1, Vessel2)=true, I) :-
    holdsFor(tugging_base(Vessel1, Vessel2)=true, Ii),
    intDurGreater(Ii, tuggingTime, I).

%---------------- trawlingSpeed -----------------%

initiatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlMin),
    thresholds(trawlingspeedMax, TrawlMax),
    Speed >= TrawlMin, Speed =< TrawlMax,
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMin, TrawlMin),
    Speed < TrawlMin.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(velocity(Vessel, Speed, _COG, _TH), T),
    thresholds(trawlingspeedMax, TrawlMax),
    Speed > TrawlMax.

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

terminatedAt(trawlingSpeed(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

%--------------- trawling --------------------%

initiatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T),
    holdsAt(withinArea(Vessel, fishingArea)=true, T).

terminatedAt(trawlingPattern(Vessel)=true, T) :-
    happensAt(end(withinArea(Vessel, fishingArea)=true), T).

holdsFor(trawling_base(Vessel)=true, If) :-
    holdsFor(trawlingSpeed(Vessel)=true, Is),
    holdsFor(trawlingPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], If), If \= [].

holdsFor(trawling(Vessel)=true, I) :-
    holdsFor(trawling_base(Vessel)=true, Ii),
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
    happensAt(gap_start(Vessel), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_speed_start(Vessel), T).

initiatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(change_in_heading(Vessel), T).

terminatedAt(sarPattern(Vessel)=true, T) :-
    happensAt(gap_start(Vessel), T).

holdsFor(inSAR_base(Vessel)=true, If) :-
    holdsFor(sarSpeed(Vessel)=true, Is),
    holdsFor(sarPattern(Vessel)=true, Ip),
    intersect_all([Is, Ip], If), If \= [].

holdsFor(inSAR(Vessel)=true, I) :-
    holdsFor(inSAR_base(Vessel)=true, Ii),
    intDurGreater(Ii, sarTime, I).

%-------- loitering --------------------------%

holdsFor(loitering(Vessel)=true, I) :-
    holdsFor(lowSpeed(Vessel)=true, Il),
    holdsFor(stopped(Vessel)=farFromPorts, Is),
    union_all([Il, Is], Im),                     
    holdsFor(withinArea(Vessel, nearCoast)=true, Icoast),
    holdsFor(anchoredOrMoored(Vessel)=true, Iaom),
    relative_complement_all(Im, [Icoast, Iaom], Ii),
    intDurGreater(Ii, loiteringTime, I).

%-------- pilotOps ---------------------------%

holdsFor(pilotOps(Vessel1, Vessel2)=true, I) :-
    holdsFor(proximity(Vessel1, Vessel2)=true, Ip),
    oneIsPilot(Vessel1, Vessel2),
    holdsFor(lowSpeed(Vessel1)=true, Il1),
    holdsFor(lowSpeed(Vessel2)=true, Il2),
    holdsFor(stopped(Vessel1)=farFromPorts, Is1),
    holdsFor(stopped(Vessel2)=farFromPorts, Is2),
    union_all([Il1, Is1], I1b),
    union_all([Il2, Is2], I2b),
    intersect_all([I1b, I2b, Ip], If), If \= [],
    holdsFor(withinArea(Vessel1, nearCoast)=true, Iw1),
    holdsFor(withinArea(Vessel2, nearCoast)=true, Iw2),
    relative_complement_all(If, [Iw1, Iw2], I).