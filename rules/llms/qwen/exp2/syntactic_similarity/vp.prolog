%--------------- status -----------%

initiatedAt(status(Motion)=proposed, T) :-
    happensAt(propose(_Agent, Motion), T),
    holdsAt(status(Motion)=null, T).

initiatedAt(status(Motion)=voting, T) :-
    happensAt(second(_Agent, Motion), T),
    holdsAt(status(Motion)=proposed, T).

initiatedAt(status(Motion)=voted, T) :-
    happensAt(close_ballot(Chair, Motion), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voting, T).

initiatedAt(status(Motion)=null, T) :-
    happensAt(declare_outcome(Chair, Motion), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

%-------------- voted ----------------------%

initiatedAt(voted(Agent, Motion)=aye, T) :-
    happensAt(cast_vote(Agent, Motion, aye), T),
    holdsAt(status(Motion)=voting, T).

initiatedAt(voted(Agent, Motion)=nay, T) :-
    happensAt(cast_vote(Agent, Motion, nay), T),
    holdsAt(status(Motion)=voting, T).

initiatedAt(voted(Agent, Motion)=null, T) :-
    happensAt(start(status(Motion)=null), T).

%------------ outcome -------------%

initiatedAt(outcome(Motion)=carried, T) :-
    happensAt(declare_outcome(Chair, Motion, carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

initiatedAt(outcome(Motion)=not_carried, T) :-
    happensAt(declare_outcome(Chair, Motion, not_carried), T),
    role_of(Chair, chair),
    holdsAt(status(Motion)=voted, T).

terminatedAt(outcome(Motion)=_CurrentResult, T) :-
    happensAt(start(status(Motion)=proposed), T).

%-------------- institutional power ---------------%

holdsFor(pow(_Agent, propose(Motion), Motion)=true, I) :-
    holdsFor(status(Motion)=null, I).

holdsFor(pow(_Agent, second(Motion), Motion)=true, I) :-
    holdsFor(status(Motion)=proposed, I).

holdsFor(pow(_Agent, vote(Motion), Motion)=true, I) :-
    holdsFor(status(Motion)=voting, I).

holdsFor(pow(Chair, close_ballot(Motion), Motion)=true, I) :-
    holdsFor(status(Motion)=voting, I),
    role_of(Chair, chair).

holdsFor(pow(Chair, declare_outcome(Motion), Motion)=true, I) :-
    holdsFor(status(Motion)=voted, I),
    role_of(Chair, chair).