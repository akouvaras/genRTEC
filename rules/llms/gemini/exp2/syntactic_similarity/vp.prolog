%--------------- status -----------%

initiatedAt(status(M) = proposed, T) :-
    happensAt(propose(_, M), T),
    \+ holdsAt(status(M) = _, T).

initiatedAt(status(M) = voting, T) :-
    happensAt(second(_, M), T),
    holdsAt(status(M) = proposed, T).

initiatedAt(status(M) = voted, T) :-
    happensAt(close_ballot(C, M), T),
    role_of(C, chair),
    holdsAt(status(M) = voting, T).

terminatedAt(status(M) = voted, T) :-
    happensAt(declare(C, M, _), T),
    role_of(C, chair),
    holdsAt(status(M) = voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Ag, M) = Vote, T) :-
    happensAt(vote(Ag, M, Vote), T),
    holdsAt(status(M) = voting, T).

terminatedAt(voted(Ag, M) = Vote, T) :-
    happensAt(end(status(M) = voted), T).

%------------ outcome -------------%

initiatedAt(outcome(M) = Result, T) :-
    happensAt(declare(C, M, Result), T),
    role_of(C, chair),
    holdsAt(status(M) = voted, T).

terminatedAt(outcome(M) = Result, T) :-
    happensAt(start(status(M) = proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(Ag, second, M) = true, I) :-
    holdsFor(status(M) = proposed, I).

holdsFor(pow(Ag, vote, M) = true, I) :-
    holdsFor(status(M) = voting, I).

holdsFor(pow(C, close_ballot, M) = true, I) :-
    role_of(C, chair),
    holdsFor(status(M) = voting, I).

holdsFor(pow(C, declare, M) = true, I) :-
    role_of(C, chair),
    holdsFor(status(M) = voted, I).

initially(pow(_, propose, _)=true).

terminatedAt(pow(Ag, propose, M)=true, T) :-
    happensAt(start(status(M)=proposed), T).

initiatedAt(pow(Ag, propose, M)=true, T) :-
    happensAt(end(status(M)=voted), T).