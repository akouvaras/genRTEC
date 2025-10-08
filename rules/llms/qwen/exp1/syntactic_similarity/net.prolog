%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T).

terminatedAt(quote(Merch, Cons, GD), T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    not holdsAt(suspended(Merch, merchant)=true, T),
    not holdsAt(suspended(Cons, consumer)=true, T).

%--------------- pow -----------%

holdsFor(pow(Cons, accept_quote, GD)=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, I_quote),
    holdsFor(suspended(Merch, merchant)=true, I_merch_susp),
    relative_complement_all(I_quote, [I_merch_susp], I_no_merch_susp),
    holdsFor(suspended(Cons, consumer)=true, I_cons_susp),
    relative_complement_all(I_no_merch_susp, [I_cons_susp], I_clean),
    I = I_clean.

%--------------- per -----------%
	 
initiatedAt(per(Merch, present_quote, Cons, GD)=true, T) :-
    happensAt(request_quote(Cons, Merch, GD), T).

terminatedAt(per(Merch, present_quote, Cons, GD), T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T).

%--------------- obl -----------%

initiatedAt(obl(Cons, send_EPO, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Cons, send_EPO, GD), T) :-
    happensAt(send_EPO(Cons, _, GD, P), T),
    price(GD, Pr),
    P =:= Pr.  

terminatedAt(obl(Cons, send_EPO, GD), T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

initiatedAt(obl(Merch, send_goods, GD)=true, T) :-
    happensAt(start(contract(Merch, Cons, GD)=true), T).

terminatedAt(obl(Merch, send_goods, GD), T) :-
    happensAt(send_goods(Merch, iServer, GD, G, K), T_send),
    decrypt(G, K, Decrypted_G),
    meets(Decrypted_G, GD),
    T = T_send.  

terminatedAt(obl(Merch, send_goods, GD), T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _), T),
    not holdsAt(per(Merch, present_quote, Cons, GD)=true, T).

initiatedAt(suspended(Merch, merchant)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Merch, send_goods, GD)=true, T).

initiatedAt(suspended(Cons, consumer)=true, T) :-
    happensAt(end(contract(Merch, Cons, GD)=true), T),
    holdsAt(obl(Cons, send_EPO, GD)=true, T).