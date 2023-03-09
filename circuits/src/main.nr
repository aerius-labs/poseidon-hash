mod poseidon;

fn main(input : Field) -> pub Field {
    let hash = poseidon::digest(input);
    hash
}