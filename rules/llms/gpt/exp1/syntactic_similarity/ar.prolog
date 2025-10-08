/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id) = true, T) :-
    happensAt(start(walking(Id) = true), T),
    holdsAt(present(Id) = true, T).

initiatedAt(person(Id) = true, T) :-
    happensAt(start(running(Id) = true), T),
    holdsAt(present(Id) = true, T).

initiatedAt(person(Id) = true, T) :-
    happensAt(start(active(Id) = true), T),
    holdsAt(present(Id) = true, T).

initiatedAt(person(Id) = true, T) :-
    happensAt(start(abrupt(Id) = true), T),
    holdsAt(present(Id) = true, T).

terminatedAt(person(Id) = true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object) = true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObject, D),
    holdsAt(person(Person) = true, T),
    holdsAt(close(Person, Object, D) = true, T).

terminatedAt(leaving_object(Person, Object) = true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2) = true, I) :-
    P1 \= P2,
    P1 @< P2,                                
    holdsFor(person(P1) = true, Ip1),
    holdsFor(person(P2) = true, Ip2),
    holdsFor(walking(P1) = true, Iw1),
    holdsFor(walking(P2) = true, Iw2),
    thresholds(moving, DMove),
    holdsFor(close(P1, P2, DMove) = true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(notInactive(P) = true, INot) :-
    holdsFor(person(P) = true, IPerson),
    holdsFor(inactive(P) = true, IInact),
    relative_complement_all(IPerson, [IInact], INot).

holdsFor(fighting(P1, P2) = true, I) :-
    P1 \= P2,
    P1 @< P2,                                   
    holdsFor(person(P1) = true, IP1),
    holdsFor(person(P2) = true, IP2),
    thresholds(fighting, Df),
    holdsFor(close(P1, P2, Df) = true, Iclose),
    holdsFor(abrupt(P1) = true, IA1),
    holdsFor(abrupt(P2) = true, IA2),
    holdsFor(notInactive(P1) = true, IN1),
    holdsFor(notInactive(P2) = true, IN2),
    intersect_all([IP1, IP2, Iclose, IA1, IN2], IF1),
    intersect_all([IP1, IP2, Iclose, IA2, IN1], IF2),
    union_all([IF1, IF2], I).