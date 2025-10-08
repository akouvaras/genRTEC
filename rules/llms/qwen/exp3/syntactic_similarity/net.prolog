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

initiatedAt(pow(Cons, accept_quote(Merch, GD))=true, T) :-
    happensAt(start(quote(Merch, Cons, GD)=true), T),
    not holdsAt(suspended(Cons, consumer)=true, T),
    not holdsAt(suspended(Merch, merchant)=true, T).

terminatedAt(pow(Cons, accept_quote(Merch, GD))=true, T) :-
    happensAt(end(quote(Merch, Cons, GD)=true), T).

terminatedAt(pow(Cons, accept_quote(Merch, GD))=true, T) :-
    happensAt(start(suspended(Cons, consumer)=true), T).

terminatedAt(pow(Cons, accept_quote(Merch, GD))=true, T) :-
    happensAt(start(suspended(Merch, merchant)=true), T).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, GD, present_quote)=true, T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, Cons, GD, present_quote)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO(GD), iServer)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO(GD), iServer)=true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, Pr),
    P =:= Pr.

terminatedAt(obl(Cons, send_EPO(GD), iServer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods(GD), iServer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T),
    not holdsAt(per(Merch, Cons, GD, present_quote)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods(GD), iServer)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO(GD), iServer)=true, T).