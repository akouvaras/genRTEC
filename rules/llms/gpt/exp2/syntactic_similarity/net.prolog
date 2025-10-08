%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not suspended(Merch, merchant),
    not suspended(Cons, consumer).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, Merch, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, Iq),
    holdsFor(suspended(Merch, merchant)=true, Im),
    holdsFor(suspended(Cons,  consumer)=true, Ic),
    relative_complement_all(Iq, [Im, Ic], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO, Merch, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO, Merch, GD)=true, T) :-
    holdsAt(epo_sent(Cons, iServer, GD)=true, T),
    holdsAt(price_matched(Cons, Merch, GD)=true, T).

terminatedAt(obl(Cons, send_EPO, Merch, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods, Cons, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods, Cons, GD)=true, T) :-
    holdsAt(goods_meet_spec(Merch, iServer, GD)=true, T).

terminatedAt(obl(Merch, send_goods, Cons, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T),
    not holdsAt(per(Merch, Cons, present_quote)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods, Cons, GD)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO, Merch, GD)=true, T).