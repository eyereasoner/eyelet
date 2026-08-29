% Eulerian circuit
% See https://en.wikipedia.org/wiki/Eulerian_path
%
% Instead of enumerating every Eulerian circuit, prove existence using
% Euler's criterion: a finite connected undirected graph has an Eulerian
% circuit iff every vertex has even degree.

:- op(1200, xfx, :+).

% Given edges
edge(v1, v2).
edge(v1, v3).
edge(v1, v5).
edge(v1, v6).
edge(v2, v3).
edge(v2, v4).
edge(v2, v6).
edge(v3, v4).
edge(v3, v6).
edge(v4, v5).
edge(v4, v6).

% Undirected adjacency
adjacent(V, U) :- edge(V, U).
adjacent(V, U) :- edge(U, V).

vertices(Vertices) :-
    findall(V, (edge(V, _); edge(_, V)), All),
    sort(All, Vertices).

degree(V, D) :-
    findall(1, adjacent(V, _), Neighbours),
    length(Neighbours, D).

all_even([]).
all_even([V | Vs]) :-
    degree(V, D),
    0 =:= D mod 2,
    all_even(Vs).

% Deterministic graph traversal.  We only need to prove that every
% vertex is reachable from one start vertex, not enumerate every route.
visit([], Seen, Seen).
visit([V | Todo], Seen0, Seen) :-
    (   member(V, Seen0)
    ->  visit(Todo, Seen0, Seen)
    ;   findall(N, adjacent(V, N), Neighbours),
        append(Neighbours, Todo, More),
        visit(More, [V | Seen0], Seen)
    ).

connected(Vertices) :-
    Vertices = [Start | _],
    visit([Start], [], Seen0),
    sort(Seen0, Seen),
    Seen = Vertices.

edge_count(N) :-
    findall(1, edge(_, _), Edges),
    length(Edges, N).

% Euler's theorem proves that this graph has an Eulerian circuit.
eulerian_verified(VertexCount, EdgeCount) :-
    vertices(Vertices),
    length(Vertices, VertexCount),
    edge_count(EdgeCount),
    connected(Vertices),
    all_even(Vertices).

true :+ eulerian_verified(6, 11).
