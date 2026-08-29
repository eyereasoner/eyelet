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


## Native EyeProlog execution

EyeProlog recognizes `:+` as an extended infix operator. When a loaded program contains `:+/2` rules and no explicit `-g/--goal` is supplied, its native forward-rule driver repeatedly solves premises and adds novel conclusions until closure. `true :+ Goal` prints successful instances, `false :+ Goal` emits `fuse(Goal)` and exits with status 2, conclusion-only variables are Skolemized, and derived `:+` rules retain universal variables.

The Eyelet compatibility prelude supplies only `stable/1`, `becomes/2`, and the historical debugging counters. The former `eyelet.pl` meta-interpreter is therefore avoided for EyeProlog runs.

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

- install EyeProlog v1.5.0 or newer (with native `:+` and explicit-only tabling)
- run [./test-eyeprolog](./test-eyeprolog) to go from [./input/](./input/) to [./output-eyeprolog/](./output-eyeprolog/)
- [./eyelet-eyeprolog](./eyelet-eyeprolog) now loads only the small compatibility prelude; EyeProlog itself executes the `:+` fixed point natively
- `eyelet.pl` remains in the repository for SWI/Trealla/Scryer, but is not on EyeProlog's execution path
- the EyeProlog launcher contains no tabling mode flag; ordinary recursion is depth-first and any predicate that needs tabling must declare `:- table ...` explicitly
- the EyeProlog comparison outputs include corrected Ackermann `[4,2]` and Takeuchi results; differential checks against Trealla/Scryer are useful when an older EyeProlog golden was incomplete
