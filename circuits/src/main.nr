mod poseidon;

fn main(inputs : Field) -> pub Field {
    let hash = poseidon::digest(inputs);
    hash
}

#[test]
fn test() {
    let inp1: [Field; 1] = [1];
    constrain main(inp1[0]) == 0;
}