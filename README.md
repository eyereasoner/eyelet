# eyelet

## eye reasoning in prolog

- besides top-down reasoning with `conclusion :- premise` rules, eyelet also supports bottom-up reasoning with `conclusion :+ premise` rules
- variables are interpreted universally except for `conclusion :+ premise` conclusion-only variables which are interpreted existentially
- linear implication is done with `becomes(from_conjunction, to_conjunction)`
- bottom-up reasoning can use `stable(n)` to fail if the deductive closure at level `n` is not yet stable
- queries are posed as `true :+ premise` and answered as `premise_inst`
- inference fuses are defined as `false :+ premise` and blown as `fuse(premise_inst)` with return code 2

## Rationale for bottom-up reasoning

- conclusion can be a conjunction
- conclusion can be `false` to blow an inference fuse
- conclusion can be `true` to pose a query
- conclusion-only variables are existentials
- avoiding loops that could occur with top-down reasoning


## EyeProlog execution

EyeProlog recognizes `:+` as an extended infix operator. When a loaded program contains `:+/2` rules and no explicit `-g/--goal` is supplied, it autoloads its bundled Prolog `library(eyelet)` fixed-point driver. The driver repeatedly solves premises and adds novel conclusions until closure. `true :+ Goal` prints successful instances, `false :+ Goal` emits `fuse(Goal)` and exits with status 2, conclusion-only variables are Skolemized, and derived `:+` rules retain universal variables.

EyeProlog bundles `library(eyelet)`, which exports the `:+` operator, `stable/1`, and `becomes/2`. Its normal library autoloader discovers the helper predicates even inside `:+` premises, so Eyelet files can run directly with `eyeprolog input/file.pl`; no EyeProlog compatibility prelude is needed. The fixed-point semantics live in that Prolog module; the JavaScript host only bootstraps it and provides private mutability/output adapters.

The portable `eyelet.pl` driver uses the same simplified structure: it inspects rules before execution rather than proving premises during setup, tracks closure growth with an explicit `changed/0` marker instead of the older `brake/0` loop, avoids fixed-point iteration for query-only files, preserves universal variables in derived `:+` rules, and prepares state predicates used by `becomes/2` where the host Prolog permits it.

## Testing

- install [SWI-Prolog](https://www.swi-prolog.org/Download.html)
- run [./test-swipl](./test-swipl) to go from [./input/](./input/) to [./output-swipl/](./output-swipl/)

__or__

- install [Trealla Prolog](https://github.com/trealla-prolog/trealla?tab=readme-ov-file#building)
- run [./test-trealla](./test-trealla) to go from [./input/](./input/) to [./output-trealla/](./output-trealla/)

__or__

- install [Scryer Prolog](https://github.com/mthom/scryer-prolog?tab=readme-ov-file#installing-scryer-prolog)
- run [./test-scryer](./test-scryer) to go from [./input/](./input/) to [./output-scryer/](./output-scryer/)

__or__

- install an EyeProlog build with Prolog-driven `:+`, explicit-only tabling, and bundled `library(eyelet)`
- run [./test-eyeprolog](./test-eyeprolog) to go from [./input/](./input/) to [./output-eyeprolog/](./output-eyeprolog/)
- or run any file directly, for example `eyeprolog input/derived-rule.pl`; [./eyelet-eyeprolog](./eyelet-eyeprolog) is only a thin compatibility alias for `eyeprolog`
- `eyelet.pl` remains in the repository for SWI/Trealla/Scryer, but is not on EyeProlog's execution path
- `fm/1` and `mf/1` debugging helpers have been removed; they were not part of the Eyelet example surface
- ordinary recursion is depth-first and predicates that need tabling must declare `:- table ...` explicitly
- the EyeProlog comparison outputs include corrected Ackermann `[4,2]` and Takeuchi results; differential checks against Trealla/Scryer are useful when an older EyeProlog golden was incomplete
