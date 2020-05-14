module Extra.Extra exposing (ternary)

--Warning this evaluates both. Don't use in recursion


ternary : a -> a -> Bool -> a
ternary item1 item2 bool =
    if bool then
        item1

    else
        item2
