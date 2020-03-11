use crate::metrics::utils::generate_bigrams;
use std::collections::hash_map::Entry::{Occupied, Vacant};
use std::collections::HashMap;

pub fn coefficient(a: &str, b: &str, ignore_case: bool) -> f64 {
    if ignore_case {
        return coefficient_impl(&a.to_lowercase(), &b.to_lowercase());
    }
    coefficient_impl(a, b)
}

fn coefficient_impl(a: &str, b: &str) -> f64 {
    let a_bigrams = generate_bigrams(&a);
    let mut b_bigrams_hash: HashMap<&str, i64> = HashMap::new();

    let mut total_bigrams = a_bigrams.len();

    {
        let b_bigrams = generate_bigrams(&b);
        for s in &b_bigrams {
            let counter = b_bigrams_hash.entry(s).or_insert(0);
            *counter += 1;
        }

        total_bigrams += b_bigrams.len();
    }

    if total_bigrams == 0 {
        return 0.0;
    }

    let mut intersections = 0;
    for bigram in &a_bigrams {
        match b_bigrams_hash.entry(bigram) {
            Vacant(_) => {}
            Occupied(entry) => {
                let counter = entry.get();
                if counter > &0 {
                    *entry.into_mut() = entry.get() - 1;
                    intersections += 1;
                }
            }
        }
    }

    2.0 * intersections as f64 / total_bigrams as f64
}
