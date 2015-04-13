-module(fn).
-export([ compose/1, compose/2
        , naive/2
        , error_monad/2
        , partial/2
        ]).

%%
%% Function composition
%%
%%   Fn = fn:compose(fun(X) -> X + X end, fun(X) -> X * 4 end)
%%   Fn(10) % => 80
%%   Fn(12) % => 96
%%
compose(F, G) ->
    fun(X) ->
        F(G(X))
    end.

%%
%% Multiple function composition
%%
%%   Fn = fn:compose(
%%       [ fun(X) -> X + 3 end
%%       , fun(X) -> X * 4 end
%%       , fun(X) -> X - 2 end
%%       ])
%%   Fn(10) % => 50
%%   Fn(13) % => 62
%%
compose([]) ->
    undefined;
compose(Fns) ->
    compose_acc(Fns, fun(X) -> X end).

compose_acc([], Acc) ->
    Acc;
compose_acc([Fn | T], Acc) ->
    compose_acc(T, compose(Fn, Acc)).

%%
%% Naive application
%%
%%   Val = fn:naive(
%%       [ fun(X) -> X + 3 end
%%       , fun(X) -> X * 4 end
%%       , fun(X) -> X - 2 end
%%       ], 10),
%%   Val % => 50
%%
naive([], Arg) ->
    Arg;
naive([Fun | Funs], Arg) ->
    naive(Funs, Fun(Arg)).

%%
%% Error monad application
%%
%%   Val1 = fn:error_monad(
%%       [ fun(X) -> {ok, X + 3} end
%%       , fun(X) -> {ok, X * 4} end
%%       , fun(X) -> {ok, X - 2} end
%%       ], 10),
%%   Val1 % => {ok, 50}
%%
%%   Val2 = fn:error_monad(
%%       [ fun(X) -> {ok, X + 3} end
%%       , fun(X) -> {ok, X * 4} end
%%       , fun(_) -> {error, something_went_wrong} end
%%       ], 10),
%%   Val2 % => {error, something_went_wrong}
%%
error_monad([], Arg) ->
    {ok, Arg};
error_monad([Fun | Funs], Arg) ->
    case Fun(Arg) of
        {ok, V} ->
            error_monad(Funs, V);
        {error, E} ->
            {error, E}
    end.

%%
%% Partial application
%%
%%   Fn1 = fn:partial(fun lists:map/2, [fun erlang:list_to_atom/1])
%%   Fn1(["test", "partial"]) % => [test, partial]
%%
%%   Fn2 = fn:partial(fun lists:foldl/3, [fun(X, Acc) -> X * Acc end, 1])
%%   Fn2([2, 5, 10]) % => 100
%%
partial(F, FixedArgs) ->
    {arity, Arity} = erlang:fun_info(F, arity),
    case length(FixedArgs) of
        L when L < Arity ->
            Args = [{var, 1, N} ||
                N <- lists:seq(1, Arity - L)],
            FArgs = [case is_function(A) of
                false -> erl_parse:abstract(A);
                true  -> {var, 1, erlang:fun_to_list(A)}
            end || A <- FixedArgs],
            Parsed = [{'fun', 1,
                        {clauses,
                            [{clause, 1, Args, [],
                                [{call, 1,
                                    {var, 1, 'F'},
                                        FArgs ++ Args}]}]}}],
            Binds = [{erlang:fun_to_list(A), A} ||
                A <- FixedArgs, is_function(A)],
            {_, R, _} = erl_eval:exprs(Parsed, [{'F', F}] ++ Binds),
            R
    end.
