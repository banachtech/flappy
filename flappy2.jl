using LinearAlgebra, Random

# Flappy-1 original configuration
# const reds = [1, 8, 15, 16, 17, 22, 29, 7, 12, 13, 14, 21, 28, 35]

# Right and up
function up(i, j)
    if i + 7 * (j - 1) == 32
        return i, j
    end
    i1, j1 = i - 1, j + 1
    if j1 > 5
        j1 = j1 % 5 # fold to the left
    end
    if i1 < 1
        return i + 1, j
    end
    return i1, j1
end

# Right and down
function down(i, j)
    if i + 7 * (j - 1) == 32
        return i, j
    end
    i1, j1 = i + 1, j + 1
    if j1 > 5
        j1 = j1 % 5 # fold to the left
    end
    if i1 > 7
        return min(7, i + 1), j
    end
    return i1, j1
end

# Recursively compute rewards matrix 
function valuesolve(rr, rg, rs, γ, reds)
    V = fill(0.0, 7, 5)
    for j ∈ 5:-1:1
        for i ∈ 7:-1:1
            id = i + 7 * (j - 1)
            if id == 32
                V[i, j] = rg
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

# Experiment for different shading patterns
function test(i, j, rr, rg, rs, γ)
    reds = shuffle([1:31; 33:35])[1:10]
    V = valuesolve(rr, rg, rs, γ, reds)
    p = trajectory(i, j, V)
    return p, V
end

# Sample test to check shortest path
runs = 50
rss = [-4, -1, 0, 1]
pathlen = zeros(Int, runs, 4)
for (l, c) in enumerate(rss)
    for k in 1:runs
        p, _ = test(2, 1, -5, 5, c, 0.9)
        pathlen[k, l] = length(p)
    end
end
