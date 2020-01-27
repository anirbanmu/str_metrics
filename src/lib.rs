#[macro_use]
extern crate helix;
extern crate unicode_segmentation;

use std::collections::HashMap;
use std::collections::hash_map::Entry::{Occupied, Vacant};
use unicode_segmentation::UnicodeSegmentation;

fn generate_bigrams(s: &str) -> Vec<&str> {
    let grapheme_indices = UnicodeSegmentation::grapheme_indices(s, true).collect::<Vec<(usize, &str)>>();

    let mut vec: Vec<&str> = Vec::new();
    if grapheme_indices.len() < 2 {
        return vec;
    }

    for i in 0..grapheme_indices.len() - 1 {
        let start = grapheme_indices[i].0;
        let end = grapheme_indices[i + 1].0 + grapheme_indices[i + 1].1.len();
        vec.push(&s[start..end])
    }

    return vec;
}

fn with_case_ignored(s: String, ignore_case: bool) -> String {
    if !ignore_case {
        return s;
    }

    return s.to_lowercase();
}

ruby! {
    class StrMetricsImpl {
        def sorensen_dice_coefficient(a: String, b: String, ignore_case: bool) -> f64 {
            let cased_a = with_case_ignored(a, ignore_case);
            let cased_b = with_case_ignored(b, ignore_case);

            let a_bigrams = generate_bigrams(&cased_a);
            let mut b_bigrams_hash: HashMap<&str, i64> = HashMap::new();

            let mut total_bigrams = a_bigrams.len();

            {
                let b_bigrams = generate_bigrams(&cased_b);
                for s in &b_bigrams {
                    let counter = b_bigrams_hash.entry(s).or_insert(0);
                    *counter += 1;
                }

                total_bigrams += b_bigrams.len();
            }

            let mut intersections = 0;
            for bigram in &a_bigrams {
                match b_bigrams_hash.entry(bigram) {
                    Vacant(_) => {},
                    Occupied(entry) => {
                        let counter = entry.get();
                        if counter > &0 {
                            *entry.into_mut() = entry.get() - 1;
                            intersections += 1;
                        }
                    },
                }
            }

            return 2.0 * intersections as f64 / total_bigrams as f64;
        }
    }
}
