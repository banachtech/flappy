using LinearAlgebra

# Flappy-1 configuration
const reds = Set([1, 8, 15, 16, 17, 22, 29, 7, 12, 13, 14, 21, 28, 35])

# Right and up
function up(i, j)
    if i + 7 * (j - 1) == 32
        return i, j
    end
    i1, j1 = i - 1, j + 1
    if isWall(i1, j1)
        return min(7, i + 1), j
    end
    return i1, j1
end

# Right and down
function down(i, j)
    if i + 7 * (j - 1) == 32
        return i, j
    end
    i1, j1 = i + 1, j + 1
    if isWall(i1, j1)
        return min(7, i + 1), j
    end
    return i1, j1
end

# Check if boundary is breached
isWall(i, j) = i < 1 || i > 7 || j < 1 || j > 5

# Recursively compute rewards matrix 
function valuesolve(rr, rg, rs, γ)
    V = fill(0.0, 7, 5)
    for j ∈ 5:-1:1
        for i ∈ 7:-1:1
            id = i + 7 * (j - 1)
            if id == 32
                V[i, j] = rg
            elseif id > 32
                V[i, j] = -Inf
            else
                r = id ∈ reds ? rr : rs
                V[i, j] = r + γ * max(V[up(i, j)...], V[down(i, j)...])
            end
        end
    end
    return V
end

# Compute optimal policy from a starting point
function trajectory(i, j, V)
    path = [i + 7 * (j - 1)]
    while true
        i1, j1 = V[up(i, j)...] > V[down(i, j)...] ? up(i, j) : down(i, j)
        id = i1 + 7 * (j1 - 1)
        push!(path, id)
        i, j = i1, j1
        if id == 32 || isinf(V[i, j])
            break
        end
    end
    return path
end

