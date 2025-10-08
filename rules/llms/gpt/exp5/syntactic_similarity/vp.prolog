%--------------- status -----------%

initially(status(Motion)=null).

initiatedAt(status(Motion)=proposed, T) :-
    happensAt(propose(_Ag, Motion), T),
    holdsAt(status(Motion)=null, T).

initiatedAt(status(Motion)=voting, T) :-
    happensAt(second(_Ag, Motion), T),
    holdsAt(status(Motion)=proposed, T).

initiatedAt(status(Motion)=voted, T) :-
    happensAt(close_ballot(Chair, Motion), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voting, T).

initiatedAt(status(Motion)=null, T) :-
    happensAt(declare(Chair, Motion, carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

initiatedAt(status(Motion)=null, T) :-
    happensAt(declare(Chair, Motion, not_carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Agent, Motion)=aye, T) :-
    happensAt(vote(Agent, Motion, aye), T),
    holdsAt(status(Motion)=voting, T).

initiatedAt(voted(Agent, Motion)=nay, T) :-
    happensAt(vote(Agent, Motion, nay), T),
    holdsAt(status(Motion)=voting, T).

initiatedAt(voted(_Agent, Motion)=null, T) :-
    happensAt(start(status(Motion)=null), T).

%------------ outcome -------------%

initiatedAt(outcome(Motion)=carried, T) :-
    happensAt(declare(Chair, Motion, carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

initiatedAt(outcome(Motion)=not_carried, T) :-
    happensAt(declare(Chair, Motion, not_carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

terminatedAt(outcome(Motion)=_Any, T) :-
    happensAt(start(status(Motion)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(Ag, propose, Motion)=true, I) :-
    holdsFor(status(Motion)=null, I).

holdsFor(pow(Ag, second, Motion)=true, I) :-
    holdsFor(status(Motion)=proposed, I).

holdsFor(pow(Ag, vote, Motion)=true, I) :-
    holdsFor(status(Motion)=voting, I).

holdsFor(pow(Ag, close_ballot, Motion)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(Motion)=voting, I).

holdsFor(pow(Ag, declare, Motion)=true, I) :-
    role_of(Ag, chair),
    holdsFor(status(Motion)=voted, I).