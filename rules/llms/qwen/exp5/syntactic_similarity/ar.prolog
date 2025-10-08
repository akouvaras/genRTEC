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
    close(Person, Object, _DistThreshold),
    person(Person)=true.

terminatedAt(leaving_object(Person, Object)=true, T) :-
    happensAt(disappear(Object), T).

/****************************************************************
 *		     MOVING					*
 ****************************************************************/

holdsFor(moving(Person1, Person2)=true, I) :-
    Person1 \= Person2,
    holdsFor(walking(Person1)=true, I1),
    holdsFor(walking(Person2)=true, I2),
    thresholds(moving, MovingThreshold),
    holdsFor(close(Person1, Person2, MovingThreshold), I3),
    intersect_all([I1, I2, I3], I).

/****************************************************************
 *		     FIGHTING					*
 ****************************************************************/

holdsFor(fighting(Person1, Person2)=true, I) :-
    Person1 \= Person2,
    person(Person1)=true,
    person(Person2)=true,
    thresholds(fighting, FightingThreshold),
    holdsFor(close(Person1, Person2, FightingThreshold), I1),
    holdsFor(abrupt(Person1)=true, I2a),
    holdsFor(abrupt(Person2)=true, I2b),
    holdsFor(inactive(Person1)=true, I3a),
    holdsFor(inactive(Person2)=true, I3b),
    relative_complement_all([[0, inf]], [I3a], I_active1),
    relative_complement_all([[0, inf]], [I3b], I_active2),
    intersect_all([I2a, I_active2], I_case1),  
    intersect_all([I2b, I_active1], I_case2),  
    union_all([I_case1, I_case2], I_union),
    intersect_all([I1, I_union], I).