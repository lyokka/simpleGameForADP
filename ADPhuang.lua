require "gnuplot"

-- matrix A: n * n
A = torch.Tensor({{1}})

-- matrix B: n * m
B = torch.Tensor({{1}})

-- matrix Q: controllability ( eye(default) n * n ) Q >= 0
Q = torch.eye(1)

-- matrix R: m * m, R > 0
R = torch.zeros(1,1):fill(1)

-- zero matrix: m * n
K0 = torch.zeros(1, 1)

N = 200
target = 0.5
x = torch.zeros(1, N+1)         -- n * (N + 1)
y = torch.zeros(1, N+1)
u = torch.zeros(1, N)

for i = 1, N do

    x[1][i] = y[1][i] - target
    u[1][i] = torch.uniform() * 0.01
    y[1][i+1] = A * x[1][i] + B * u[1][i]

end

P_1 = torch.zeros(1, 1)
index = 1
H = torch.zeros(2, 2)
H33 = torch.zeros(1, 1)
H13 = torch.zeros(1, 1)
H11 = torch.zeros(1, 1)
K = torch.zeros(1, 1)

c = 0

-- function kronecker product
function kron(A,B)

    local m, n = A:size(1), A:size(2)
    local p, q = B:size(1), B:size(2)
    local C = torch.Tensor(m*p,n*q)

    for i=1,m do
        for j=1,n do
           C[{{(i-1)*p+1,i*p},{(j-1)*q+1,j*q}}] = torch.mul(B, A[i][j])
        end
    end

    return C

end

for count = 1, 10 do

    X = torch.zeros(N-2*10+1, 3)
    Y = torch.zeros(N-2*10+1)

    c = c + 1

    for j = 10, N-10 do

        temp = torch.Tensor({{u[1][j]},{x[1][j]}})
        temp1 = kron(temp, temp)
        psi = temp1:gather(1, torch.LongTensor{{1}, {2}, {4}})

        phi = x[1][j+1] * (H33 - H13:transpose(1, 2) * torch.inverse(R + H11) * H13) * x[1][j+1]

        X[{{j-9}, {}}] = psi:transpose(1,2)
        Y[j-9] = x[{{}, {j+1}}]:transpose(1,2) * Q * x[{{}, {j+1}}] + phi

    end

    solution = torch.inverse(X:transpose(1,2) * X) * X:transpose(1,2) * Y

    l = 1
    temp5 = torch.zeros(2, 2)
    for m = 1, 2 do
        for n = m, 2 do
            temp5[{{m},{n}}]:fill(solution[l]/2)
            l = l + 1
        end
    end

    H = temp5 + temp5:transpose(1,2)
    H33 = H[{{2},{2}}]
    H13 = H[{{1}, {2}}]
    H11 = H[{{1}, {1}}]
    K = torch.inverse(R + H11) * H13
    print(K)
end
