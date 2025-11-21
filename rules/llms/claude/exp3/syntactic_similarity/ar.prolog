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
    holdsFor(walking(P1)=true, Iwalk1),
    holdsFor(walking(P2)=true, Iwalk2),
    thresholds(movingThr, MovingThr),
    holdsFor(close(P1, P2, MovingThr)=true, Iclose),
    intersect_all([Iwalk1, Iwalk2, Iclose], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, Iclose),
    holdsFor(abrupt(P1)=true, Iabrupt1),
    holdsFor(abrupt(P2)=true, Iabrupt2),
    union_all([Iabrupt1, Iabrupt2], Iabrupt),
    holdsFor(inactive(P1)=true, Iinactive1),
    holdsFor(inactive(P2)=true, Iinactive2),
    union_all([Iinactive1, Iinactive2], Iinactive),
    relative_complement_all(Iclose, [Iinactive], Itemp),
    intersect_all([Itemp, Iabrupt], I).