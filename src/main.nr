// global nOuts: u8 = 1;

fn main(nInputs : Field, inputs : [Field], output : Field) {
    let N_ROUNDS_P[16] = [56, 57, 56, 60, 60, 63, 64, 63, 60, 66, 60, 65, 70, 60, 64, 68];
    let t = nInputs + 1;
    let nRoundsF = 8;
    let nRoundsP = N_ROUNDS_P[t-2];
    let C[t*nRoundsF + nRoundsP] = POSEIDON_C(t);
    let S[N_ROUNDS_P[t-2]* (t*2-1)] = POSEIDON_S(t);
    let M[t][t] = POSEIDON_M(t);
    let P[t][t] = POSEIDON_P(t);

    let mut arkInp[nRoundsF][t], arkOut[nRoundsF][t];
    let mut sigmaFInp[nRoundsF][t], sigmaFOut[nRoundsF][t];
    let mut sigmaPInp[nRoundsP], sigmaPOut[nRoundsP];
    let mut mixInp[nRoundsF-1], mixOut[nRoundsF-1];
    let mut mixSInp[nRoundsP], mixSOut[nRoundsP];
    let mut mixLastInp[nOuts][t], mixLastOut[nOuts];

    for j in 0..t {
        if j>0 {
            arkInp[0][j] = inputs[j-1];
        } else {
            arkInp[0][j] = initialState;
        }
    }
    arkOut[0] = Ark(arkInp[0], t, C, r);

    for i in 0..nRoundsF/2-1 {
        for j in 0..t {
            if r==0 {
                sigmaFInp[r][j] = arkOut[0][j];
            } else {
                sigmaFInp[r][j] = mixOut[r-1][j];
            }
            sigmaFOut[r][j] = Sigma(sigmaFInp[r][j]);
        }

        for j in 0..t {
            arkInp[r+1][j] = sigmaFOut[r][j];
        }
        arkOut[r+1] = Ark(arkInp[r+1], t, C, r);

        for j in 0..t {
            mixInp[r][j] = arkOut[r+1][j];
        }
        mixOut[r] = Mix(mixInp[r], r, M);
    }

    for j in 0..t {
        sigmaFInp[nRoundsF/2-1][j] = mixOut[nRoundsF/2-2][j];
        sigmaFOut[nRoundsF/2-1][j] = Sigma(sigmaFInp[nRoundsF/2-1][j]);
    }

    for j in 0..t {
        arkInp[nRoundsF/2][j] = sigmaFOut[nRoundsF/2-1][j];
    }
    arkOut[nRoundsF/2] = Ark(arkOut[nRoundsF/2],t, C, (nRoundsF/2)*t);

    for j in 0..t {
        mixInp[nRoundsF/2-1][j] = arkOut[nRoundsF/2][j];
    }
    mixOut[nRoundsF/2-1] = Mix(mixInp[nRoundsF/2-1], t, P);

    for r in 0..nRoundsP {
        if r==0 {
            sigmaPInp[r] = mixOut[nRoundsF/2-1][0];
        } else {
            sigmaPInp[r] = mixSOut[r-1][0];
        }
        sigmaPOut[r] = Sigma(sigmaPInp[r]);

        for j in 0..t {
            if j==0 {
                maxSInp[r][j] = sigmaPOut[r] + C[(nRoundsF/2+1)*t + r];
            } else {
                if r==0 {
                    mixSInp[r][j] = mixOut[nRoundsF/2-1][j];
                } else {
                    mixSInp[r][j] = mixSOut[r-1][j];
                }
            }
        }
        mixSOut[r] = MixS(mixSInp[r], t, S, r);
    }

    for r in 0..nRoundsF/2-1 {
        for j in 0..t {
            if r==0 {
                sigmaFInp[nRoundsF/2 + r][j] = mixSOut[nRoundsP-1][j];
            } else {
                sigmaFInp[nRoundsF/2 + r][j] = mixOut[nRoundsF/2+r-1][j];
            }
            sigmaFOut[nRoundsF/2 + r][j] = Sigma(sigmaFInp[nRoundsF/2 + r][j]);
        }

        for j in 0..t {
            arkInp[nRoundsF/2 + r + 1][j] = sigmaFOut[nRoundsF/2 + r][j];
        }
        arkOut[nRoundsF/2 + r + 1] = Ark(arkInp[nRoundsF/2 + r + 1], t, C, (nRoundsF\2+1)*t + nRoundsP + r*t);

        for j in 0..t {
            mixInp[nRoundsF/2 + r][j] = arkOut[nRoundsF/2 + r + 1][j];
        }
        mixOut[nRoundsF/2 + r] = Mix(mixInp[nRoundsF/2 + r], t, M);
    }

    for j in 0..t {
        sigmaFInp[nRoundsF-1][j] = mixOut[nRoundsF-2][j];
        sigmaFOut[nRoundsF-1][j] = Sigma(sigmaFInp[nRoundsF-1][j]);
    }

    let mut out: [Field; nOuts];
    for i in 0..nOuts {
        for j in 0..t {
            mixLastInp[i][j] = sigmaFOut[nRoundsF-1][j];
        }
        mixLastOut[i] = MixLast(mixLastInp[i], t, M, i);
        out[i] = mixLastOut[i];
    }

    // TODO: Change below code
    let out = 0;
    constrain output == out;
}

fn Ark(in: &[Field], t: u8, C: &[Field], r: u8) -> [Field] {
    let mut out[t];
    for i in 0..t {
        out[i] = in[i] + C[i + r];
    }
    out
}

fn Sigma(in: Field) -> Field {
    let in2 = in*in;
    let in4 = in2*in2;
    in4*in
}

fn Mix(in: &[Field], t: u8, M: &[&[Field]]) -> [Field] {
    let mut lc;
    for i in 0..t {
        lc = 0;
        for j in 0..t {
            lc += M[j][i]*in[j];
        }
        out[i] = lc;
    }
    out
}