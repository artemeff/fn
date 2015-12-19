-module(fn_tests).
-include_lib("eunit/include/eunit.hrl").

compose_fn_test() ->
    Fn = fn:compose(fun(X) -> X + X end, fun(X) -> X * 4 end),
    ?assertEqual(80, Fn(10)),
    ?assertEqual(96, Fn(12)).

compose_fns_test() ->
    Fn = fn:compose(
        [ fun(X) -> X + 3 end
        , fun(X) -> X * 4 end
        , fun(X) -> X - 2 end
        ]),
    ?assertEqual(50, Fn(10)),
    ?assertEqual(62, Fn(13)).

naive_test() ->
    Val = fn:naive(
        [ fun(X) -> X + 3 end
        , fun(X) -> X * 4 end
        , fun(X) -> X - 2 end
        ], 10),
    ?assertEqual(50, Val).

monad_ok_test() ->
    Val = fn:error_monad(
        [ fun(X) -> {ok, X + 3} end
        , fun(X) -> {ok, X * 4} end
        , fun(X) -> {ok, X - 2} end
        ], 10),
    ?assertEqual({ok, 50}, Val).

monad_error_test() ->
    Val = fn:error_monad(
        [ fun(X) -> {ok, X + 3} end
        , fun(X) -> {ok, X * 4} end
        , fun(_) -> {error, something} end
        ], 10),
    ?assertEqual({error, something}, Val).

partial_test() ->
    Fn1 = fn:partial(fun lists:map/2,
        [fun erlang:list_to_atom/1]),
    ?assertEqual([test, partial], Fn1(["test", "partial"])),

    Fn2 = fn:partial(fun lists:foldl/3,
        [fun(X, Acc) -> X * Acc end, 1]),
    ?assertEqual(100, Fn2([2, 5, 10])).
