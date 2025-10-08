/****************************************************************
 *		     PERSON					*
 ****************************************************************/

initiatedAt(person(Id)=true, T) :-
    happensAt(start(walking(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(running(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(active(Id)=true), T).

initiatedAt(person(Id)=true, T) :-
    happensAt(start(abrupt(Id)=true), T).

terminatedAt(person(Id)=true, T) :-
    happensAt(disappear(Id), T).

/****************************************************************
 *		     LEAVING OBJECT				*
 ****************************************************************/

initiatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(appear(Object), T),
    thresholds(leavingObject, MaxDist),
    holdsAt(close(Person, Object, MaxDist)=true, T),
    holdsAt(person(Person)=true, T).

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    thresholds(moving, MaxDist),
    holdsFor(close(Person1, Person2, MaxDist)=true, I3),
    intersect_all([I1, I2, I3], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 @< Person2,
    thresholds(fighting, MaxDist),
    holdsFor(close(Person1, Person2, MaxDist)=true, I_prox),
    holdsFor(abrupt(Person1)=true, I1a),
    holdsFor(inactive(Person2)=true, I2_inactive),
    relative_complement_all([[0, infinity]], [I2_inactive], I2_not_inactive),
    intersect_all([I1a, I2_not_inactive], I_case1),
    holdsFor(abrupt(Person2)=true, I1b),
    holdsFor(inactive(Person1)=true, I1_inactive),
    relative_complement_all([[0, infinity]], [I1_inactive], I1_not_inactive),
    intersect_all([I1b, I1_not_inactive], I_case2),
    union_all([I_case1, I_case2], I_behavior),
    intersect_all([I_prox, I_behavior], I).