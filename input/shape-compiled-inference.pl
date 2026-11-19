% Shape-compiled inference for repeated OWL/SKOS/QUDT reasoning on RDF messages
%
% Idea (after rdfjs-inference-engine SHACL-OPTIMIZATION.md, but in eyelet itself):
% an input shape says what every message looks like and an output shape says
% what the application wants back. A planner reads both shapes plus the
% ontology and derives one-step specialized rules with :+ that map message
% triples straight to wanted output triples. These derived rules are then the
% only rules that touch the messages:
%
% - subPropertyOf/equivalentProperty/inverseOf/SymmetricProperty chains are
%   folded into one rule per (input property, wanted output property)
% - domain/range/subClassOf/equivalentClass chains are folded into one typing
%   rule per (input term, wanted output class)
% - SKOS exactMatch value mappings become a lookup table for the target scheme
% - QUDT unit conversions are folded into a constant factor
% - ontology axioms that cannot be reached from the input shape are never used
% - message triples outside the input shape are never matched (closed shape)
% - typing that the input shape already guarantees for the focus node is not
%   compiled again from domain axioms (shape-based subsumption)
%
% The compiled rules printed below are plain eyelet rules, so they can be
% saved once and reused for every later message without the ontology.

:- op(1200, xfx, :+).

% ------------------------------------------------------------------------
% ontology: RDF triples t(Subject, Predicate, Object)
% ------------------------------------------------------------------------

% OWL/RDFS
t('ex:observedBy', 'rdfs:subPropertyOf', 'ex:producedBy').
t('ex:producedBy', 'rdfs:subPropertyOf', 'sosa:madeBySensor').
t('sosa:madeBySensor', 'rdfs:domain', 'sosa:Observation').
t('sosa:madeBySensor', 'rdfs:range', 'sosa:Sensor').
t('sosa:madeObservation', 'owl:inverseOf', 'sosa:madeBySensor').
t('ex:about', 'rdfs:subPropertyOf', 'sosa:hasFeatureOfInterest').
t('sosa:hasFeatureOfInterest', 'rdfs:domain', 'sosa:Observation').
t('sosa:hasFeatureOfInterest', 'rdfs:range', 'sosa:FeatureOfInterest').
t('sosa:isFeatureOfInterestOf', 'owl:inverseOf', 'sosa:hasFeatureOfInterest').
t('ex:quantity', 'owl:equivalentProperty', 'sosa:observedProperty').
t('ex:elevation', 'rdfs:subPropertyOf', 'schema:elevation').
t('ex:Reading', 'rdfs:subClassOf', 'ex:Measurement').
t('ex:Measurement', 'owl:equivalentClass', 'sosa:Observation').
t('sosa:Sensor', 'rdfs:subClassOf', 'sosa:System').

% axioms that are not reachable from the input shape
t('ex:calibratedBy', 'rdfs:subPropertyOf', 'prov:wasAttributedTo').
t('prov:wasAttributedTo', 'rdfs:domain', 'prov:Entity').
t('prov:wasAttributedTo', 'rdfs:range', 'prov:Agent').
t('ex:Device', 'owl:equivalentClass', 'sosa:Platform').

% SKOS
t('ex:temp', 'skos:exactMatch', 'quantitykind:Temperature').
t('quantitykind:RelativeHumidity', 'skos:exactMatch', 'ex:rh').
t('ex:temp', 'skos:closeMatch', 'wd:Q11466').
t('quantitykind:Temperature', 'skos:inScheme', 'qudt:QuantityKinds').
t('quantitykind:RelativeHumidity', 'skos:inScheme', 'qudt:QuantityKinds').

% QUDT
t('unit:KiloM', 'qudt:hasQuantityKind', 'quantitykind:Length').
t('unit:KiloM', 'qudt:conversionMultiplier', 1000).
t('unit:M', 'qudt:hasQuantityKind', 'quantitykind:Length').
t('unit:M', 'qudt:conversionMultiplier', 1).

% ------------------------------------------------------------------------
% shapes: shape(Direction, Shape, target_class(Class))
%         shape_property(Direction, Shape, Property, Constraint)
% ------------------------------------------------------------------------

% what every message looks like (trusted and closed)
shape(in, 'ex:ReadingShape', target_class('ex:Reading')).

% what the application wants back
shape(out, 'ex:ObservationShape', target_class('sosa:Observation')).
shape(out, 'ex:SensorShape', target_class('sosa:Sensor')).
shape(out, 'ex:FeatureShape', target_class('sosa:FeatureOfInterest')).

shape_property(in, 'ex:ReadingShape', 'ex:observedBy', node_kind(iri)).
shape_property(in, 'ex:ReadingShape', 'ex:about', node_kind(iri)).
shape_property(in, 'ex:ReadingShape', 'ex:quantity', node_kind(iri)).
shape_property(in, 'ex:ReadingShape', 'ex:elevation', unit('unit:KiloM')).

shape_property(out, 'ex:ObservationShape', 'sosa:madeBySensor', node_kind(iri)).
shape_property(out, 'ex:ObservationShape', 'sosa:observedProperty', in_scheme('qudt:QuantityKinds')).
shape_property(out, 'ex:ObservationShape', 'schema:elevation', unit('unit:M')).
shape_property(out, 'ex:SensorShape', 'sosa:madeObservation', node_kind(iri)).
shape_property(out, 'ex:FeatureShape', 'sosa:isFeatureOfInterestOf', node_kind(iri)).

% ------------------------------------------------------------------------
% messages: msg(Message, Subject, Predicate, Object)
% ------------------------------------------------------------------------

msg(m1, 'ex:r1', 'rdf:type', 'ex:Reading').
msg(m1, 'ex:r1', 'ex:observedBy', 'ex:thermo7').
msg(m1, 'ex:r1', 'ex:about', 'ex:greenhouse3').
msg(m1, 'ex:r1', 'ex:quantity', 'ex:temp').
msg(m1, 'ex:r1', 'ex:elevation', 2).
msg(m1, 'ex:r1', 'ex:debugInfo', 'firmware 1.4').

msg(m2, 'ex:r2', 'rdf:type', 'ex:Reading').
msg(m2, 'ex:r2', 'ex:observedBy', 'ex:hygro2').
msg(m2, 'ex:r2', 'ex:about', 'ex:greenhouse3').
msg(m2, 'ex:r2', 'ex:quantity', 'ex:rh').
msg(m2, 'ex:r2', 'ex:elevation', 3).

% ------------------------------------------------------------------------
% planner: ontology vocabulary
% ------------------------------------------------------------------------

sub_property(P, Q) :-
    t(P, 'rdfs:subPropertyOf', Q).
sub_property(P, Q) :-
    t(P, 'owl:equivalentProperty', Q).
sub_property(P, Q) :-
    t(Q, 'owl:equivalentProperty', P).

inverse_property(P, Q) :-
    t(P, 'owl:inverseOf', Q).
inverse_property(P, Q) :-
    t(Q, 'owl:inverseOf', P).
inverse_property(P, P) :-
    t(P, 'rdf:type', 'owl:SymmetricProperty').

sub_class(C, D) :-
    t(C, 'rdfs:subClassOf', D).
sub_class(C, D) :-
    t(C, 'owl:equivalentClass', D).
sub_class(C, D) :-
    t(D, 'owl:equivalentClass', C).

exact_match(A, B) :-
    t(A, 'skos:exactMatch', B).
exact_match(A, B) :-
    t(B, 'skos:exactMatch', A).

unit_factor(Ui, Uo, F) :-
    t(Ui, 'qudt:hasQuantityKind', K),
    t(Uo, 'qudt:hasQuantityKind', K),
    t(Ui, 'qudt:conversionMultiplier', Mi),
    t(Uo, 'qudt:conversionMultiplier', Mo),
    0 is Mi mod Mo,
    F is Mi // Mo.

flip(fwd, inv).
flip(inv, fwd).

wanted_class(C) :-
    shape(out, _, target_class(C)).

% the subject of an input shape property is that shape's focus node
focus_typed(P, C) :-
    shape_property(in, Sh, P, _),
    shape(in, Sh, target_class(K)),
    node_type(class(K), subj, C).

% a compiled message rule
compiled_rule((out(M, S, P, O) :+ Body)) :-
    (out(M, S, P, O) :+ Body).

% ------------------------------------------------------------------------
% planner: forward reachability from the input shape
% ------------------------------------------------------------------------

% reach(P, Q, Dir): a P triple entails a Q triple, inverted when Dir = inv
reach(P, P, fwd) :+
    shape_property(in, _, P, _).

reach(P, R, D) :+
    reach(P, Q, D),
    sub_property(Q, R).

reach(P, R, E) :+
    reach(P, Q, D),
    inverse_property(Q, R),
    flip(D, E).

% node_type(Source, Position, Class): the subject/object of an input term has Class
node_type(class(K), subj, K) :+
    shape(in, _, target_class(K)).

node_type(prop(P), subj, C) :+
    reach(P, Q, fwd),
    t(Q, 'rdfs:domain', C).

node_type(prop(P), obj, C) :+
    reach(P, Q, fwd),
    t(Q, 'rdfs:range', C).

node_type(prop(P), obj, C) :+
    reach(P, Q, inv),
    t(Q, 'rdfs:domain', C).

node_type(prop(P), subj, C) :+
    reach(P, Q, inv),
    t(Q, 'rdfs:range', C).

node_type(X, Pos, D) :+
    node_type(X, Pos, C),
    sub_class(C, D).

% SKOS lookup table, only for schemes that the output shape asks for
concept_map(S, A, B) :+
    shape_property(out, _, _, in_scheme(S)),
    exact_match(A, B),
    t(B, 'skos:inScheme', S).

% ------------------------------------------------------------------------
% planner: compile one-step message rules
% ------------------------------------------------------------------------

% same constraint on both sides: copy the triple
(
    out(M, S, Q, O) :+
        msg(M, S, P, O)
) :+
    reach(P, Q, fwd),
    shape_property(in, _, P, C),
    shape_property(out, _, Q, C).

(
    out(M, O, Q, S) :+
        msg(M, S, P, O)
) :+
    reach(P, Q, inv),
    shape_property(in, _, P, node_kind(iri)),
    shape_property(out, _, Q, node_kind(iri)).

% QUDT unit conversion folded into a constant factor
(
    out(M, S, Q, W) :+
        msg(M, S, P, V),
        W is V*F
) :+
    reach(P, Q, fwd),
    shape_property(in, _, P, unit(Ui)),
    shape_property(out, _, Q, unit(Uo)),
    Ui \== Uo,
    unit_factor(Ui, Uo, F).

% SKOS value mapping into the scheme the output shape asks for
(
    out(M, S, Q, B) :+
        msg(M, S, P, A),
        concept_map(Sc, A, B)
) :+
    reach(P, Q, fwd),
    shape_property(in, _, P, node_kind(iri)),
    shape_property(out, _, Q, in_scheme(Sc)).

% typing from the input target class
(
    out(M, S, 'rdf:type', C) :+
        msg(M, S, 'rdf:type', K)
) :+
    node_type(class(K), subj, C),
    wanted_class(C).

% typing from domain/range, unless the input shape already guarantees it
(
    out(M, S, 'rdf:type', C) :+
        msg(M, S, P, _)
) :+
    node_type(prop(P), subj, C),
    wanted_class(C),
    stable(1),
    \+ focus_typed(P, C).

(
    out(M, O, 'rdf:type', C) :+
        msg(M, _, P, O)
) :+
    node_type(prop(P), obj, C),
    wanted_class(C).

% ------------------------------------------------------------------------
% queries
% ------------------------------------------------------------------------

% the compiled plan
true :+
    compiled_rule(_).

true :+
    concept_map(_, _, _).

% the output messages
true :+
    out(_, _, _, _).
