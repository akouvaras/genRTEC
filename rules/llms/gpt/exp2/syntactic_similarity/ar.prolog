/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(visible(Id)=true, T) :-
    happensAt(appear(Id), T).

terminatedAt(visible(Id)=true, T) :-
    happensAt(disappear(Id), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T),
    holdsAt(visible(Id)=true, T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T),
    holdsAt(visible(Id)=true, T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObject, Dth),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, Dth)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(P1, P2)=true, I) :-
    thresholds(moving, Dth),                       
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(walking(P1)=true, Iw1),
    holdsFor(walking(P2)=true, Iw2),
    holdsFor(close(P1, P2, Dth)=true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(P1, P2)=true, I) :-
    thresholds(fighting, Dth),
    holdsFor(person(P1)=true, Ip1),
    holdsFor(person(P2)=true, Ip2),
    holdsFor(close(P1, P2, Dth)=true, Ic),
    holdsFor(abrupt(P1)=true, Ia1),
    holdsFor(abrupt(P2)=true, Ia2),
    holdsFor(inactive(P1)=true, In1),
    holdsFor(inactive(P2)=true, In2),
    intersect_all([Ic, Ip1, Ip2, Ia1], K1),
    relative_complement_all(K1, [In2], If1),
    intersect_all([Ic, Ip1, Ip2, Ia2], K2),
    relative_complement_all(K2, [In1], If2),
    union_all([If1, If2], I).