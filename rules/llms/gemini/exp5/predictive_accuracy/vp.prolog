
/*********************
      status(M)
 *********************/

% deadlines on status:
fi(status(M)=proposed, status(M)=null, 10).
fi(status(M)=voting, status(M)=voted, 10).
fi(status(M)=voted, status(M)=null, 10).

initially(status(_M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, _Outcome), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(status(M)=OldValue, T) :-
    initiatedAt(status(M)=NewValue, T),
    OldValue \== NewValue.

/*********************
    voted(V,M)=Vote
 *********************/

initiatedAt(voted(Ag, M)=Vote, T) :-
    happensAt(vote(Ag, M, Vote), T),
    Vote=aye,
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=Vote, T) :-
    happensAt(vote(Ag, M, Vote), T),
    Vote=nay,
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T),
    holdsAt(voted(Ag, M)=_PreviousVote, T),
    _PreviousVote \== null.

terminatedAt(voted(Ag, M)=OldValue, T) :-
    initiatedAt(voted(Ag, M)=NewValue, T),
    OldValue \== NewValue.

/*****************************
      outcome(M)=Outcome
 *****************************/

initiatedAt(outcome(M)=Outcome, T) :-
    happensAt(declare(C, M, Outcome), T),
    Outcome=carried,
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=Outcome, T) :-
    happensAt(declare(C, M, Outcome), T),
    Outcome=not_carried,
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Outcome, T) :-
    happensAt(start(status(M)=proposed), T).

/*********************
  INSTITUTIONAL POWER
 *********************/

holdsFor(pow(propose(_P,M))=true, I) :-
	holdsFor(status(M)=null, I).

holdsFor(pow(second(_S,M))=true, I) :-
	holdsFor(status(M)=proposed, I).

holdsFor(pow(vote(_V,M))=true, I) :-
	holdsFor(status(M)=voting, I).

holdsFor(pow(close_ballot(C,M))=true, I) :-
	role_of(C,chair),
	holdsFor(status(M)=voting, I).

holdsFor(pow(declare(C,M))=true, I) :-
	role_of(C,chair),
	holdsFor(status(M)=voted, I).

% The elements of these domains are derived from the ground arguments of input entitites
dynamicDomain(person(_P)).

% Grounding of input entities

grounding(propose(Ag, M)) 		:- person(Ag), motion(M).
grounding(second(Ag, M)) 		:- person(Ag), motion(M).
grounding(vote(Ag, M, _)) 		:- person(Ag), motion(M).
grounding(close_ballot(Ag, M)) 		:- person(Ag), motion(M).
grounding(declare(Ag, M, _)) 		:- person(Ag), motion(M).

% Grounding of output entities 

grounding(status(M)=null)			:- queryMotion(M).
grounding(status(M)=proposed)			:- queryMotion(M).
grounding(status(M)=voting)			:- queryMotion(M).
grounding(status(M)=voted)			:- queryMotion(M).
grounding(status(M)=OldValue)			:- queryMotion(M).

grounding(voted(Ag,M)=null)			:- person(Ag),role_of(Ag,voter), queryMotion(M).
grounding(voted(Ag,M)=aye)			:- person(Ag),role_of(Ag,voter), queryMotion(M).
grounding(voted(Ag,M)=nay)			:- person(Ag),role_of(Ag,voter), queryMotion(M).
grounding(voted(Ag,M)=OldValue)			:- person(Ag),role_of(Ag,voter), queryMotion(M).


grounding(outcome(M)=Outcome)			:- queryMotion(M).

grounding(pow(propose(Ag,M))=true)		:- person(Ag), queryMotion(M).
grounding(pow(second(Ag,M))=true)		:- person(Ag), queryMotion(M).
grounding(pow(vote(Ag,M))=true)			:- person(Ag), queryMotion(M).
grounding(pow(close_ballot(C,M))=true)		:- person(C), role_of(C,chair), queryMotion(M).
grounding(pow(declare(C,M))=true)		:- person(C), role_of(C,chair), queryMotion(M).