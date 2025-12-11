/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(P)=true, T) :-
    happensAt(start(walking(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(running(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(active(P)=true), T).

initiatedAt(person(P)=true, T) :-
    happensAt(start(abrupt(P)=true), T).

terminatedAt(person(P)=true, T) :-
    happensAt(disappear(P), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    holdsAt(person(Person)=true, T),
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    thresholds(movingThr, MovingThr),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(close(P1, P2, MovingThr)=true, Ic),
    intersect_all([Ip1, Iw1, Ip2, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(close(P1, P2, FightingThr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(inactive(P2)=true, Ii2),
    complement_all([Ii2], Inot_i2),
    intersect_all([Ia1, Inot_i2], I_caseA),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Ii1),
    complement_all([Ii1], Inot_i1),
    intersect_all([Ia2, Inot_i1], I_caseB),
    union_all([I_caseA, I_caseB], I_cond3),
    intersect_all([Ip1, Ip2, Ic, I_cond3], I).
