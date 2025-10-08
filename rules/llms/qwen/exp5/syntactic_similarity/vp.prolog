%--------------- status -----------%

initially(status(M)=null).

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

%-------------- voted ----------------------%

initially(voted(Agent, M)=null).

initiatedAt(voted(Agent, M)=aye, T) :-
    happensAt(vote(Agent, M, aye), T),
    holdsAt(status(M)=voting, T).

initiatedAt(voted(Agent, M)=nay, T) :-
    happensAt(vote(Agent, M, nay), T),
    holdsAt(status(M)=voting, T).

%------------ outcome -------------%

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

%-------------- institutional power ---------------%

initiatedAt(pow(Agent, propose, M)=true, T) :-
    holdsAt(status(M)=null, T).

initiatedAt(pow(Agent, second, M)=true, T) :-
    holdsAt(status(M)=proposed, T).

initiatedAt(pow(Agent, vote, M)=true, T) :-
    holdsAt(status(M)=voting, T).

initiatedAt(pow(Chair, close_ballot, M)=true, T) :-
    holdsAt(status(M)=voting, T),
    role_of(Chair, chair).

initiatedAt(pow(Chair, declare_outcome, M)=true, T) :-
    holdsAt(status(M)=voted, T),
    role_of(Chair, chair).