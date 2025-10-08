
/*********************
      status(M)
 *********************/

% deadlines on status:
fi(status(M)=proposed, status(M)=null, 10).
fi(status(M)=voting, status(M)=voted, 10).
fi(status(M)=voted, status(M)=null, 10).

initially(status(_M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(Chair, M), T),
    role_of(Chair, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Chair, M, carried), T),
    role_of(Chair, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Chair, M, not_carried), T),
    role_of(Chair, chair),
    holdsAt(status(M)=voted, T).

/*********************
    voted(V,M)=Vote
 *********************/
 
initially(voted(Agent, M)=null).


initiatedAt(voted(Agent, M)=aye, T) :-
    happensAt(vote(Agent, M, aye), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Agent, M)=nay, T) :-
    happensAt(vote(Agent, M, nay), T),
    holdsAt(status(M)=voting, T).

/*****************************
      outcome(M)=Outcome
 *****************************/

initiatedAt(outcome(M)=carried, T) :-
    happensAt(declare(Chair, M, carried), T),
    role_of(Chair, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(outcome(M)=not_carried, T) :-
    happensAt(declare(Chair, M, not_carried), T),
    role_of(Chair, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Result, T) :-
    happensAt(start(status(M)=proposed), T).

/*********************
  INSTITUTIONAL POWER
 *********************/
 
initiatedAt(pow(propose(_P,M))=true, T) :-
    holdsAt(status(M)=null, T).

initiatedAt(pow(second(_S,M))=true, T) :-
    holdsAt(status(M)=proposed, T).

initiatedAt(pow(vote(_V,M))=true, T) :-
    holdsAt(status(M)=voting, T).

initiatedAt(pow(close_ballot(C,M))=true, T) :-
    holdsAt(status(M)=voting, T),
    role_of(Chair, chair).

initiatedAt(pow(declare(C,M))=true, T) :-
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).

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

grounding(voted(Ag,M)=null)			:- person(Ag),role_of(Ag,voter), queryMotion(M).
grounding(voted(Ag,M)=aye)			:- person(Ag),role_of(Ag,voter), queryMotion(M).
grounding(voted(Ag,M)=nay)			:- person(Ag),role_of(Ag,voter), queryMotion(M).

grounding(outcome(M)=carried)			:- queryMotion(M).
grounding(outcome(M)=not_carried)		:- queryMotion(M).
grounding(outcome(M)=_Result)		:- queryMotion(M).

grounding(pow(propose(Ag,M))=true)		:- person(Ag), queryMotion(M).
grounding(pow(second(Ag,M))=true)		:- person(Ag), queryMotion(M).
grounding(pow(vote(Ag,M))=true)			:- person(Ag), queryMotion(M).
grounding(pow(close_ballot(C,M))=true)		:- person(C), role_of(C,chair), queryMotion(M).
grounding(pow(declare(C,M))=true)		:- person(C), role_of(C,chair), queryMotion(M).