/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(walking(Entity)=true), T),
    holdsAt(present(Entity)=true, T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(running(Entity)=true), T),
    holdsAt(present(Entity)=true, T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(active(Entity)=true), T),
    holdsAt(present(Entity)=true, T).

initiatedAt(person(Entity)=true, T) :-
    happensAt(start(abrupt(Entity)=true), T),
    holdsAt(present(Entity)=true, T).

terminatedAt(person(Entity)=true, T) :-
    happensAt(disappear(Entity), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObject, Thr),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, Thr)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    thresholds(moving, Thr),
    holdsFor(close(P1, P2, Thr)=true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    thresholds(fighting, Thr),
    holdsFor(close(P1, P2, Thr)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Ii1),
    holdsFor(inactive(P2)=true, Ii2),
    intersect_all([Ip1, Ip2, Ic, Ia1], IrawA),
    relative_complement_all(IrawA, [Ii2], IA),
    intersect_all([Ip1, Ip2, Ic, Ia2], IrawB),
    relative_complement_all(IrawB, [Ii1], IB),
    union_all([IA, IB], I).