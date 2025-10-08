%--------------- status -----------%

initially(status(_)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_, M), T),
    holdsAt(status(M)=null, T).

terminatedAt(status(M)=null, T) :-
    happensAt(propose(_, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_, M), T),
    holdsAt(status(M)=proposed, T).

terminatedAt(status(M)=proposed, T) :-
    happensAt(second(_, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

terminatedAt(status(M)=voting, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(C, M, _Outcome), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(status(M)=voted, T) :-
    happensAt(declare(C, M, _Outcome), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Ag, M)=Vote, T) :-
    happensAt(vote(Ag, M, Vote), T),
    holdsAt(status(M)=voting, T).

terminatedAt(voted(Ag, M)=null, T) :-
    happensAt(vote(Ag, M, _), T),
    holdsAt(status(M)=voting, T),
    holdsAt(voted(Ag, M)=null, T).

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T),
    holdsAt(voted(Ag, M)=_, T).

terminatedAt(voted(Ag, M)=Vote, T) :-
    happensAt(start(status(M)=null), T),
    holdsAt(voted(Ag, M)=Vote, T),
    Vote \== null.

%------------ outcome -------------%

initiatedAt(outcome(M)=Outcome, T) :-
    happensAt(declare(C, M, Outcome), T),
    role_of(C, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Outcome, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(_, propose, M)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(_, second, M)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(_, vote, M)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, close_ballot, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, declare, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voted, I).