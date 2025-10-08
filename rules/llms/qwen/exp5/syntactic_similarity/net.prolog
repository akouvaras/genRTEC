%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not holdsAt(suspended(Merch)=true, T),
    not holdsAt(suspended(Cons)=true, T).

%--------------- pow -----------%

initiatedAt(pow(Cons, accept_quote, Merch, GD)=true, T) :-
    happensAt(start(quote(Merch, Cons, GD)=true), T),
    not holdsAt(suspended(Merch)=true, T),
    not holdsAt(suspended(Cons)=true, T).

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote, Cons, GD)=true, T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, present_quote, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, ExpectedPrice),
    P =:= ExpectedPrice.

terminatedAt(obl(Cons, send_EPO, iServer, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods, iServer, GD)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T),
    not holdsAt(per(Merch, present_quote, Cons, GD)=true, T).

initiatedAt(suspended(Merch)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods, iServer, GD)=true, T).

initiatedAt(suspended(Cons)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO, iServer, GD)=true, T).