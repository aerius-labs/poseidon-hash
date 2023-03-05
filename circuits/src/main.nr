mod poseidon;

fn main(inputs : [Field; 1], output: Field) -> pub Field {
    let mut hash = poseidon::digest(inputs);
    if hash != output {
        hash = 1;
    }
    hash
}

#[test]
fn test() {
    let inp1: [Field; 1] = [1];
    let output: Field = 0;
    constrain main(inp1, output) == 1;
}