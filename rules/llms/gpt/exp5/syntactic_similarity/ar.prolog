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
    thresholds(leavingObject, D),
    holdsAt(person(Person)=true, T),
    holdsAt(close(Person, Object, D)=true, T).

terminatedAt(leaving_object(_Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    Person1 \= Person2,
    thresholds(moving, D),
    holdsFor(person(Person1)=true, Ip1),
    holdsFor(person(Person2)=true, Ip2),
    holdsFor(walking(Person1)=true, Iw1),
    holdsFor(walking(Person2)=true, Iw2),
    holdsFor(close(Person1, Person2, D)=true, Ic),
    intersect_all([Ip1, Ip2, Iw1, Iw2, Ic], I), I \= [].

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 \= Person2,
    thresholds(fighting, D),
    holdsFor(person(Person1)=true, Ip1),
    holdsFor(person(Person2)=true, Ip2),
    holdsFor(close(Person1, Person2, D)=true, Ic),
    holdsFor(abrupt(Person1)=true, Ia1),
    holdsFor(abrupt(Person2)=true, Ia2),
    holdsFor(inactive(Person1)=true, In1),
    holdsFor(inactive(Person2)=true, In2),
    relative_complement_all(Ia1, [In2], Icase12),   
    relative_complement_all(Ia2, [In1], Icase21),  
    union_all([Icase12, Icase21], Ieither),
    intersect_all([Ip1, Ip2, Ic, Ieither], I), I \= [].