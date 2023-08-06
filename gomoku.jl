using Printf

const HEIGHT::Int32 = 15
const WIDTH::Int32 = 15

@enum STONE NONE WHITE BLACK
@enum ERROR_TYPE E_POSITION E_NONE

struct Position
    x::Int32
    y::Int32
end

function get_player_str(player::STONE)::String
    player == WHITE && return "WHITE"
    player == BLACK && return "BLACK"
end

function change_player(player::STONE)::STONE
    player == WHITE && return BLACK
    player == BLACK && return WHITE
end

function error(err_type::ERROR_TYPE)::String
    err_type == E_POSITION && return "Can't put the position.\n"
    err_type == E_NONE && return ""
end

function put_to_goban(goban::Array{STONE, 2}, player::STONE, pos::Position)
    err_type = E_NONE
    if goban[pos.x, pos.y] == NONE
        goban[pos.x, pos.y] = player
    else
        err_type = E_POSITION
    end
    return goban, err_type
end

function init_goban(goban::Array{STONE, 2})
    for x in 1:WIDTH
        for y in 1:HEIGHT
            goban[x, y] = NONE
        end
    end
    return goban
end

function print_goban(goban::Array{STONE, 2})
    function hline()
        for x in 1:WIDTH
            print("+-")
        end
        println("+")
    end
    hline()
    for y in 1:HEIGHT
        for x in 1:WIDTH
            set_go = " "
            goban[x, y] == WHITE && (set_go = "○")
            goban[x, y] == BLACK && (set_go = "●")
            @printf "+%c" set_go
        end
        println("+")
        hline()
    end
end

function check_clear(goban::Array{STONE, 2}, player::STONE)::Bool
    # 横
    check_sum = 0
    for y in 1:HEIGHT
        before_go = NONE
        for x in 1:WIDTH
            before_go != goban[x, y] && (check_sum = 0)
            goban[x, y] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x, y]
        end
    end

    # 縦
    check_sum = 0
    for x in 1:WIDTH
        before_go = NONE
        for y in 1:HEIGHT
            before_go != goban[x, y] && (check_sum = 0)
            goban[x, y] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x, y]
        end
    end

    # 左->右斜め
    check_sum = 0
    for y in 1:HEIGHT-4
        before_go = NONE
        for x in 1:WIDTH-(y-1)
            before_go != goban[x, x + (y - 1)] && (check_sum = 0)
            goban[x, x + (y - 1)] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x, x + (y - 1)]
        end
    end

    check_sum = 0
    for y in 1:HEIGHT-4
        before_go = NONE
        for x in 1:WIDTH-(y-1)
            before_go != goban[x + (y - 1), x] && (check_sum = 0)
            goban[x + (y - 1), x] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x + (y - 1), x]
        end
    end

    # 右<-左斜め
    check_sum = 0
    for y in 1:HEIGHT-4
        before_go = NONE
        for x in WIDTH:-1:y
            before_go != goban[x, WIDTH - x + y] && (check_sum = 0)
            goban[x, WIDTH - x + y] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x, WIDTH - x + y]
        end
    end

    check_sum = 0
    for y in 1:HEIGHT-4
        before_go = NONE
        for x in WIDTH:-1:y
            before_go != goban[x - (y - 1), WIDTH - x + 1] && (check_sum = 0)
            goban[x - (y - 1), WIDTH - x + 1] == player && (check_sum += 1)
            check_sum == 5 && return true
            before_go = goban[x - (y - 1), WIDTH - x + 1]
        end
    end

    return false
end

function main()
    goban::Array{STONE, 2} = Array{STONE, 2}(undef, WIDTH, HEIGHT)
    goban = init_goban(goban)
    player::STONE = WHITE

    
    while true
        print_goban(goban)
        @printf "player %s: " get_player_str(player)
        pos::Position = readline(stdin) |> split |> x -> parse.(Int32, x) |> x -> Position(x[1], x[2])
        if (pos.x > WIDTH || pos.x < 1 ) || (pos.y > HEIGHT || pos.y < 1) 
            error(E_POSITION) |> print
            continue
        end
        goban, err_type = put_to_goban(goban, player, pos)
        if err_type == E_POSITION
            error(E_POSITION) |> print
            continue
        end
        if check_clear(goban, player)
            print_goban(goban)
            @printf "player %s Win!\n" get_player_str(player)
            break
        end
        player = change_player(player)
    end
    @printf "End."
end

main()