%--------------- status -----------%

initially(status(M)=null).

initiatedAt(status(M)=proposed, T) :-
    happensAt(propose(_Ag, M), T),
    holdsAt(status(M)=null, T).

initiatedAt(status(M)=voting, T) :-
    happensAt(second(_Ag, M), T),
    holdsAt(status(M)=proposed, T).

initiatedAt(status(M)=voted, T) :-
    happensAt(close_ballot(Ag, M), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voting, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Ag, M, carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

initiatedAt(status(M)=null, T) :-
    happensAt(declare(Ag, M, not_carried), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Ag, M)=Vote, T) :-
    happensAt(vote(Ag, M, Vote), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Ag, M)=null, T) :-
    happensAt(start(status(M)=null), T).

%------------ outcome -------------%

initiatedAt(outcome(M)=Outcome, T) :-
    happensAt(declare(Ag, M, Outcome), T),
    role_of(Ag, chair),
    holdsAt(status(M)=voted, T).

terminatedAt(outcome(M)=_Outcome, T) :-
    happensAt(start(status(M)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(_Ag, propose, M)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(_Ag, second, M)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(_Ag, vote, M)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(Ag, close_ballot, M)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(Ag, declare, M)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(M)=voted, I).