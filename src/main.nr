mod poseidon;

fn main(inputs : [Field; 10], out : Field) {
    let hash = poseidon::digest(inputs);
    constrain out == hash;
}