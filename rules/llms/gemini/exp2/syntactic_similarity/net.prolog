%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD, Pr) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, Pr), T).

terminatedAt(quote(Merch, Cons, GD, Pr) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD) = true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD, _), T),
    \+ holdsAt(suspended(Merch) = true, T),
    \+ holdsAt(suspended(Cons) = true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, Merch, GD) = true, I) :-
    holdsFor(quote(Merch, Cons, GD, _), I_Quote),
    holdsFor(suspended(Merch) = true, I_SuspendedM),
    holdsFor(suspended(Cons) = true, I_SuspendedC),
    relative_complement_all(I_Quote, [I_SuspendedM, I_SuspendedC], I).

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote, Cons, GD) = true, T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, present_quote, Cons, GD) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, pay, Merch, GD) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl(Cons, pay, Merch, GD) = true, T) :-
    happensAt(send_EPO(Cons, _, GD, P), T),
    price(GD, P).

terminatedAt(obl(Cons, pay, Merch, GD) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T).

initiatedAt(obl(Merch, send_goods, Cons, GD) = true, T) :-
    happensAt(start(contract(Merch, Cons, GD) = true), T).

terminatedAt(obl(Merch, send_goods, Cons, GD) = true, T) :-
    happensAt(send_goods(Merch, _, GD, G, K), T),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD).

terminatedAt(obl(Merch, send_goods, Cons, GD) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch) = true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T),
    \+ holdsAt(per(Merch, present_quote, Cons, GD) = true, T).

initiatedAt(suspended(Merch) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl(Merch, send_goods, Cons, GD) = true, T).

initiatedAt(suspended(Cons) = true, T) :-
    happensAt(end(contract(Merch, Cons, GD) = true), T),
    holdsAt(obl(Cons, pay, Merch, GD) = true, T).