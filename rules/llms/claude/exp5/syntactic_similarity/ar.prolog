/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    not happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    not happensAt(disappear(Id), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(P, Obj)=true, T) :-
    happensAt(appear(Obj), T),
    holdsAt(person(P)=true, T),
    thresholds(leavingObject, LeavingObjectThreshold),
    holdsAt(close(P, Obj, LeavingObjectThreshold)=true, T).

terminatedAt(leaving_object(P, Obj)=true, T) :-
    happensAt(disappear(Obj), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    holdsFor(walking(P1)=true, I1),
    holdsFor(walking(P2)=true, I2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(P1, P2, MovingThreshold)=true, Ic),
    intersect_all([I1, I2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fighting, FightingThreshold),
    holdsFor(close(P1, P2, FightingThreshold)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    union_all([Ia1, Ia2], Ia),
    holdsFor(inactive(P1)=true, Ii1),
    holdsFor(inactive(P2)=true, Ii2),
    union_all([Ii1, Ii2], Ii),
    relative_complement_all(Ic, [Ii], Ic_filtered),
    intersect_all([Ic_filtered, Ia], I).