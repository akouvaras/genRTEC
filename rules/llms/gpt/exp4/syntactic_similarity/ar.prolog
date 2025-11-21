/****************************************************************
 *		     PERSON					*
 ****************************************************************/
 
initiatedAt(present(Id)=true, T) :-
    happensAt(appear(Id), T).

terminatedAt(present(Id)=true, T) :-
    happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    holdsAt(present(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    holdsAt(present(Id)=true, T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T),
    Person \= Object.

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    P1 \= P2,
    thresholds(movingThr, MovingThr),
    holdsFor(close(P1, P2, MovingThr)=true, Ic),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    intersect_all([Ic, Iw1, Iw2, Ip1, Ip2], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    P1 \= P2,
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Ii1),
    holdsFor(inactive(P2)=true, Ii2),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    intersect_all([Ic, Ia1, Ip1, Ip2], IcaseA0),
    relative_complement_all(IcaseA0, [Ii2], IcaseA),
    intersect_all([Ic, Ia2, Ip1, Ip2], IcaseB0),
    relative_complement_all(IcaseB0, [Ii1], IcaseB),
    union_all([IcaseA, IcaseB], I).