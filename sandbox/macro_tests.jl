## could be done either way I guess
function checking_scope(custom_type)
    @eval function hello(a::$custom_type)
        println("Hello tmp")
    end
    return nothing
end
macro checking_scope(custom_type)
    @show custom_type
    expr = :(
    function hello(a::$custom_type)
        println("hello 3")
    end
    )
    return expr
end

checking_scope(String)
#
@checking_scope(String)

##
function check_scope()
    # puts into global scope
    @eval a=1
    @eval b=2
    return nothing
end