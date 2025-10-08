%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not holdsAt(suspended(Merch, merchant)=true, T),
    not holdsAt(suspended(Cons, consumer)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, Merch, GD, accept_quote)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, Iq),
    holdsFor(suspended(Merch, merchant)=true, ImMerch),
    holdsFor(suspended(Cons, consumer)=true, ImCons),
    relative_complement_all(Iq, [ImMerch, ImCons], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, Merch, GD, send_EPO)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, Merch, GD, send_EPO)=true, T) :-
    happensAt(send_EPO(Cons, _IServer, GD, P), T),
    price(GD, Pr),
    P =:= Pr.

terminatedAt(obl(Cons, Merch, GD, send_EPO)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, Cons, GD, send_goods)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, Cons, GD, send_goods)=true, T) :-
    happensAt(start(goods_valid(Merch, GD)=true), T).

terminatedAt(obl(Merch, Cons, GD, send_goods)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T),
    not holdsAt(per(Merch, Cons, present_quote)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, Cons, GD, send_goods)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, Merch, GD, send_EPO)=true, T).