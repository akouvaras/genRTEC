%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    \+ holdsAt(suspended(Merch)=true, T),
    \+ holdsAt(suspended(Cons)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, (Merch, GD))=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, I_quote),
    holdsFor(suspended(Merch)=merchant, I_susp_merch),
    holdsFor(suspended(Cons)=consumer, I_susp_cons),
    relative_complement_all(I_quote, [I_susp_merch, I_susp_cons], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons)=true, T) :-
    happensAt(request_quote(Cons, Merch, _), T).

terminatedAt(per(Merch, Cons)=true, T) :-
    happensAt(present_quote(Merch, Cons, _, _), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay(Merch, GD))=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, pay(Merch, GD))=true, T) :-
    happensAt(send_EPO(Cons, _, GD, P), T),
    price(GD, P),
    holdsAt(obl(Cons, pay(Merch, GD))=true, T).

terminatedAt(obl(Cons, pay(Merch, GD))=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods(Cons, GD))=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods(Cons, GD))=true, T) :-
    happensAt(send_goods(Merch, _, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD),
    holdsAt(obl(Merch, send_goods(Cons, GD))=true, T).

terminatedAt(obl(Merch, send_goods(Cons, GD))=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch)=merchant, T) :-
    happensAt(present_quote(Merch, Cons, _, _), T),
    \+ holdsAt(per(Merch, Cons)=true, T).

initiatedAt(suspended(Merch)=merchant, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods(Cons, GD))=true, T).

initiatedAt(suspended(Cons)=consumer, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, pay(Merch, GD))=true, T).