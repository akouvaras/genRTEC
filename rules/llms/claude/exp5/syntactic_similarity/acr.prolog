/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    \+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    \+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    \+ happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    \+ happensAt(disappear(Id), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

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
    holdsFor(walking(P1)=true, I1),
    holdsFor(walking(P2)=true, I2),
    thresholds(movingThr, MovingThr),
    holdsFor(close(P1, P2, MovingThr)=true, I3),
    intersect_all([I1, I2, I3], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    union_all([Ia1, Ia2], Iu),
    holdsFor(inactive(P1)=true, Ii1),
    holdsFor(inactive(P2)=true, Ii2),
    union_all([Ii1, Ii2], Iinactive),
    relative_complement_all(Ic, [Iinactive], Iclose_active),
    intersect_all([Iclose_active, Iu], I).
