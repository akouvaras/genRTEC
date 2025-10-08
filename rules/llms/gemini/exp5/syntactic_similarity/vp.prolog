%--------------- status -----------%

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

%-------------- voted ----------------------%

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

%------------ outcome -------------%

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

%-------------- institutional power ---------------%

holdsFor(pow(_Ag, propose, M)=true, I) :-
    holdsFor(status(M)=null, I).

holdsFor(pow(_Ag, second, M)=true, I) :-
    holdsFor(status(M)=proposed, I).

holdsFor(pow(_Ag, vote, M)=true, I) :-
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, close_ballot, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voting, I).

holdsFor(pow(C, declare, M)=true, I) :-
    role_of(C, chair),
    holdsFor(status(M)=voted, I).