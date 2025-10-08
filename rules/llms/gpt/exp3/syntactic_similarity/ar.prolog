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

initiatedAt(leaving_object(Person, Obj)=true, T) :-
    happensAt(appear(Obj), T),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Obj, leavingObject)=true, T),
    Person \= Obj.

terminatedAt(leaving_object(Person, Obj)=true, T) :-
    happensAt(disappear(Obj), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    P1 \= P2,
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(close(P1, P2, moving)=true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    P1 \= P2,
    holdsFor(close(P1, P2, fighting)=true, Ic),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, Ii1),
    holdsFor(inactive(P2)=true, Ii2),
    intersect_all([Ic, Ip1, Ip2, Ia1], IbaseA),
    relative_complement_all(IbaseA, [Ii2], IokA),
    intersect_all([Ic, Ip1, Ip2, Ia2], IbaseB),
    relative_complement_all(IbaseB, [Ii1], IokB),
    union_all([IokA, IokB], I).