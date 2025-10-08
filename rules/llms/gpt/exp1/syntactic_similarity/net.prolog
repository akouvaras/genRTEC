%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD) = true, T),
    not holdsAt(suspended(Merch, merchant) = true, T),
    not holdsAt(suspended(Cons, consumer) = true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote(Merch, GD)) = true, I) :-
    holdsFor(quote(Merch, Cons, GD) = true, Iq),
    holdsFor(suspended(Merch, merchant) = true, Im),
    holdsFor(suspended(Cons,  consumer) = true, Ic),
    relative_complement_all(Iq, [Im, Ic], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, Cons, present_quote) = true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(Merch, Cons, present_quote) = true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl_pay(Cons, Merch, GD) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl_pay(Cons, Merch, GD) = true, T) :-
    happensAt(send_EPO(Cons, iServer, GD, P), T),
    price(GD, Pr),
    P = Pr.

terminatedAt(obl_pay(Cons, Merch, GD) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T).

initiatedAt(obl_send_goods(Merch, Cons, GD) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl_send_goods(Merch, Cons, GD) = true, T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl_send_goods(Merch, Cons, GD) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant) = true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T),
    not holdsAt(per(Merch, Cons, present_quote) = true, T).

initiatedAt(suspended(Merch, merchant) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl_send_goods(Merch, Cons, GD) = true, T).

initiatedAt(suspended(Cons, consumer) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl_pay(Cons, Merch, GD) = true, T).
