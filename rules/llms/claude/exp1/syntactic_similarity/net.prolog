%--------------- quote -----------%

initiatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(present_quote(Merch, Cons, GD, _Pr), T).

terminatedAt(quote(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T).

%--------------- contract -----------%

initiatedAt(contract(Merch, Cons, GD)=true, T) :-
    happensAt(accept_quote(Cons, Merch, GD), T),
    holdsAt(quote(Merch, Cons, GD)=true, T),
    \+ holdsAt(suspended(Merch, merchant)=true, T),
    \+ holdsAt(suspended(Cons, consumer)=true, T).

%--------------- pow -----------%

holdsFor(pow(accept_quote(Cons,Merch))=true, I) :-
    holdsFor(quote(Merch, Cons, GD)=true, Iq),
    holdsFor(suspended(Merch, merchant)=true, Ism),
    holdsFor(suspended(Cons, consumer)=true, Isc),
    complement_all([Ism], Icm),
    complement_all([Isc], Icc),
    intersect_all([Iq, Icm, Icc], I).

%--------------- per -----------%
	 
initiatedAt(per(present_quote(Merch,Cons))=true, T) :-
    happensAt(request_quote(Cons, Merch, _GD), T).

terminatedAt(per(present_quote(Merch,Cons))=true, T) :-
    happensAt(present_quote(Merch, Cons, _GD, _Pr), T).

%--------------- obl -----------%

initiatedAt(obl(send_EPO(Cons,iServer,GD))=true, T) :-
	happensAt(start(contract(_Merch,Cons,GD)=true), T).

terminatedAt(obl(send_EPO(Cons,iServer,GD))=true, T) :-
	happensAt(send_EPO(Cons,iServer,GD,Pr), T),
	price(GD,Pr).

terminatedAt(obl(send_EPO(Cons,iServer,GD))=true, T) :-
	happensAt(end(contract(_Merch,Cons,GD)=true), T).

initiatedAt(obl(send_goods(Merch,iServer,GD))=true, T) :-
	happensAt(start(contract(Merch,_Cons,GD)=true), T).

terminatedAt(obl(send_goods(Merch,iServer,GD))=true, T) :-
	happensAt(send_goods(Merch,iServer,GD,G,K), T),
	decrypt(G,K,Decrypted_G), 
	meets(Decrypted_G,GD).	

terminatedAt(obl(send_goods(Merch,iServer,GD))=true, T1, T, T2) :-
	happensAt(end(contract(Merch,_Cons,GD)=true), T).

%--------------- suspended -----------%

initiatedAt(suspended(Merch,merchant)=true, T) :-
	happensAt(present_quote(Merch,Cons,_GD,_Pr), T),
	\+ holdsAt(per(present_quote(Merch,Cons))=true, T).

initiatedAt(suspended(Merch,merchant)=true, T) :-
	happensAt(end(contract(Merch,_Cons,GD)=true), T),
	holdsAt(obl(send_goods(Merch,iServer,GD))=true, T).

initiatedAt(suspended(Cons,consumer)=true, T) :-
	happensAt(end(contract(_Merch,Cons,GD)=true), T),
	holdsAt(obl(send_EPO(Cons,iServer,GD))=true, T).
