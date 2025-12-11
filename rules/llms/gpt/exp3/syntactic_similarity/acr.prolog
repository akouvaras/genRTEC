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
    thresholds(leavingObjectThr, LeavingObjectThr),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, LeavingObjectThr)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    P1 \= P2,
    thresholds(movingThr, MovingThr),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(close(P1, P2, MovingThr)=true, Ic12),
    holdsFor(close(P2, P1, MovingThr)=true, Ic21),
    union_all([Ic12, Ic21], Ic),
    intersect_all([Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    P1 \= P2,
    thresholds(fightingThr, FightingThr),
    holdsFor(close(P1, P2, FightingThr)=true, Ic12),
    holdsFor(close(P2, P1, FightingThr)=true, Ic21),
    union_all([Ic12, Ic21], Iclose),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Iin1),
    holdsFor(inactive(P2)=true, Iin2),
    intersect_all([Ia1, Iclose, Ip1, Ip2], ItempA),
    relative_complement_all(ItempA, [Iin2], IA),
    intersect_all([Ia2, Iclose, Ip1, Ip2], ItempB),
    relative_complement_all(ItempB, [Iin1], IB),
    union_all([IA, IB], I).
