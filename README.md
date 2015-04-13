### fn [![Build Status](https://img.shields.io/travis/artemeff/fn.svg)](https://travis-ci.org/artemeff/fn)

---

### Function composition

```erlang
Fn = fn:compose(fun(X) -> X + X end, fun(X) -> X * 4 end)
Fn(10) % => 80
Fn(12) % => 96
```

---

### Multiple function composition

```erlang
Fn = fn:compose(
    [ fun(X) -> X + 3 end
    , fun(X) -> X * 4 end
    , fun(X) -> X - 2 end
    ])
Fn(10) % => 50
Fn(13) % => 62
```

---

### Naive application

```erlang
Val = fn:naive(
    [ fun(X) -> X + 3 end
    , fun(X) -> X * 4 end
    , fun(X) -> X - 2 end
    ], 10),
Val % => 50
```

---

### Error monad application

```erlang
Val1 = fn:error_monad(
    [ fun(X) -> {ok, X + 3} end
    , fun(X) -> {ok, X * 4} end
    , fun(X) -> {ok, X - 2} end
    ], 10),
Val1 % => {ok, 50}

Val2 = fn:error_monad(
    [ fun(X) -> {ok, X + 3} end
    , fun(X) -> {ok, X * 4} end
    , fun(_) -> {error, something_went_wrong} end
    ], 10),
Val2 % => {error, something_went_wrong}
```

---

### Partial application

```erlang
Fn1 = fn:partial(fun lists:map/2, [fun erlang:list_to_atom/1])
Fn1(["test", "partial"]) % => [test, partial]

Fn2 = fn:partial(fun lists:foldl/3, [fun(X, Acc) -> X * Acc end, 1])
Fn2([2, 5, 10]) % => 100
```

---

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
